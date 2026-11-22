// node common/pi/tests/inline-commands.smoke.mjs
// Set PI_PACKAGE_DIR for an installation outside Homebrew/npm's layouts.
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { existsSync, realpathSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, resolve } from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import { fileURLToPath } from 'node:url';

function findPi() {
  if (process.env.PI_PACKAGE_DIR) return resolve(process.env.PI_PACKAGE_DIR);
  const bin = dirname(realpathSync(execFileSync('which', ['pi'], { encoding: 'utf8' }).trim()));
  return [resolve(bin, '..'), resolve(bin, '../libexec/lib/node_modules/@earendil-works/pi-coding-agent')]
    .find(p => existsSync(resolve(p, 'dist/core/extensions/loader.js')));
}
const root = findPi();
assert.ok(root, 'Point PI_PACKAGE_DIR at pi-coding-agent');
const requirePi = createRequire(resolve(root, 'package.json'));
const { CombinedAutocompleteProvider } = await import(requirePi.resolve('@earendil-works/pi-tui'));
const { loadExtensions } = await import(`${root}/dist/core/extensions/loader.js`);
const { KeybindingsManager } = await import(`${root}/dist/core/keybindings.js`);
const { getEditorTheme, initTheme } = await import(`${root}/dist/modes/interactive/theme/theme.js`);
initTheme('dark');
const extension = fileURLToPath(new URL('../extensions/inline-commands.ts', import.meta.url));
const { extensions, errors, runtime } = await loadExtensions([extension], process.cwd());
assert.deepEqual(errors, []);
const commands = [
  { name: 'review', source: 'extension', description: 'Review changes' },
  { name: 'skill:audit', source: 'skill', description: 'Audit changes' },
];
runtime.getCommands = () => commands;
const tui = { requestRender() {}, terminal: { rows: 24, columns: 80 } };
const args = [tui, getEditorTheme(), new KeybindingsManager()];
let editor;
const provider = new CombinedAutocompleteProvider([...commands, { name: 'settings' }], process.cwd());
const ui = {
  setEditorComponent(factory) { editor = factory(...args); },
  getEditorComponent() { return undefined; },
};
const ctx = { hasUI: true, ui, cwd: process.cwd() };
for (const handler of extensions[0].handlers.get('session_start') ?? []) await handler({ type: 'session_start' }, ctx);
editor.setAutocompleteProvider(provider);
const submitted = [];
editor.onSubmit = text => submitted.push(text);
const type = text => { for (const ch of text) editor.handleInput(ch); };
async function waitForMenu() {
  for (let n = 0; n < 100 && !editor.isShowingAutocomplete(); n++) await delay(10);
  assert.ok(editor.isShowingAutocomplete(), `Expected autocomplete for ${editor.getText()}`);
}
for (const [key, prefix, command, expected] of [
  ['\t', 'rev', 'review', '/review check this carefully'],
  ['\r', 'set', 'settings', '/settings carefully'],
  ['\t', 'skill:au', 'skill:audit', '/skill:audit check this carefully'],
]) {
  type(`check this /${prefix}`);
  await waitForMenu();
  const count = submitted.length;
  editor.handleInput(key);
  assert.equal(editor.getText(), `check this /${command} `);
  assert.equal(submitted.length, count, 'Accepting a suggestion must not submit');
  type('carefully');
  editor.handleInput('\r');
  assert.deepEqual(submitted.slice(count), [expected]);
}
for (const [text, pasted] of [['inspect /tmp/file', false], ['inspect src/review', false], ['inspect /review', true]]) {
  if (pasted) editor.handleInput(`\x1b[200~${text}\x1b[201~`);
  else type(text);
  await delay(100);
  assert.equal(editor.isShowingAutocomplete(), false);
  editor.handleInput('\r');
  assert.equal(submitted.at(-1), text);
}
console.log('Inline commands: Tab, Enter, dispatch, paths and bracketed paste passed.');
