import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { AutocompleteItem, AutocompleteProvider, EditorComponent } from "@earendil-works/pi-tui";

// Leave leading commands (including their argument providers), @mentions and paths alone.
function inlineToken(lines: string[], line: number, col: number) {
	const before = [...lines.slice(0, line), lines[line].slice(0, col)].join("\n");
	if (before.trimStart().startsWith("/")) return undefined;
	return /\s(\/[\w:.-]*)$/u.exec(before)?.[1];
}

type Selection = { before: string; command: string };

function argumentsAfter(text: string, { before, command }: Selection) {
	const anchor = before + command;
	if (!text.startsWith(anchor)) return undefined;
	const after = text.slice(anchor.length);
	return !after || /^\s/u.test(after) ? after.trim() : undefined;
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		if (!ctx.hasUI) return;
		const previous = ctx.ui.getEditorComponent?.();
		ctx.ui.setEditorComponent((tui, theme, keys) => {
			const editor: EditorComponent = previous?.(tui, theme, keys) ?? new CustomEditor(tui, theme, keys);
			const install = editor.setAutocompleteProvider?.bind(editor);
			if (!install) return editor;
			let accepted: Selection | undefined;
			editor.setAutocompleteProvider = (native) => {
				const choices = new WeakSet<AutocompleteItem>();
				const provider: AutocompleteProvider = {
					triggerCharacters: native.triggerCharacters,
					shouldTriggerFileCompletion: native.shouldTriggerFileCompletion?.bind(native),
					async getSuggestions(lines, line, col, options) {
						const token = inlineToken(lines, line, col);
						if (!token || options.force) return native.getSuggestions(lines, line, col, options);
						const suggestions = await native.getSuggestions([token], 0, token.length, options);
						if (suggestions?.prefix === token) suggestions.items.forEach((item) => choices.add(item));
						return suggestions;
					},
					applyCompletion(lines, line, col, item, prefix) {
						if (!choices.has(item) || inlineToken(lines, line, col) !== prefix)
							return native.applyCompletion(lines, line, col, item, prefix);
						const start = lines[line].slice(0, col - prefix.length);
						const command = `/${item.value}`;
						accepted = { before: [...lines.slice(0, line), start].join("\n"), command };
						const updated = [...lines];
						updated[line] = `${start}${command} ${lines[line].slice(col)}`;
						return { lines: updated, cursorLine: line, cursorCol: start.length + command.length + 1 };
					},
				};
				install(provider);
			};

			// Pi assigns onSubmit after the factory returns. Keep wrapping its latest callback.
			let submit = editor.onSubmit;
			Object.defineProperty(editor, "onSubmit", {
				configurable: true,
				set(callback: EditorComponent["onSubmit"]) { submit = callback; },
				get: () => (text: string) => {
					const selection = accepted;
					accepted = undefined;
					if (selection) {
						const before = selection.before.trimStart(); // Pi trims the submitted text.
						const after = argumentsAfter(text, { ...selection, before });
						if (after !== undefined) {
							// getCommands lists extensions, templates and skills, not builtins.
							const takesProse = pi.getCommands().some(({ name }) => `/${name}` === selection.command);
							text = [selection.command, takesProse && before.trimEnd(), after].filter(Boolean).join(" ");
						}
					}
					return submit?.call(editor, text);
				},
			});

			const setText = editor.setText.bind(editor);
			editor.setText = (text) => { accepted = undefined; setText(text); };
			const input = editor.handleInput.bind(editor);
			editor.handleInput = (data) => {
				const old = editor.getText();
				if (accepted && argumentsAfter(old, accepted) === undefined) accepted = undefined;
				input(data);
				const text = editor.getText();
				if (text === old) return;
				if (accepted && argumentsAfter(text, accepted) === undefined) accepted = undefined;
				// Pi 1.6 excludes '/' from provider triggerCharacters. Only nudge its normal
				// request path for a typed inline command, never for paste or menu navigation.
				if (!/^[\w:./-]$/u.test(data)) return;
				const native = editor as EditorComponent & {
					getCursor?(): { line: number; col: number };
					tryTriggerAutocomplete?(): void;
				};
				const cursor = native.getCursor?.();
				if (cursor && inlineToken(text.split("\n"), cursor.line, cursor.col)) native.tryTriggerAutocomplete?.();
			};
			return editor;
		});
	});
}
