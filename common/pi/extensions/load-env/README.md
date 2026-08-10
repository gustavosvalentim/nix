# Pi Load Env

A global Pi extension that loads `~/.pi/.env` into Pi's process environment at startup.

This makes variables such as `FIRECRAWL_API_KEY` available to extensions that read
`process.env` directly.

## Behavior

- Loads `~/.pi/.env` when the extension starts.
- Does nothing when the file is absent.
- Preserves variables explicitly set before Pi starts.
- Does not print, store, or expose secret values.

The file must use Node-compatible dotenv syntax. It is parsed by Node's built-in
`process.loadEnvFile()`; shell commands and shell-only expressions are not supported.

## Installation

This extension lives in Pi's global auto-discovered extension directory:

```text
~/.pi/agent/extensions/load-env/
```

Pi discovers `index.ts` through the `pi.extensions` entry in `package.json`. Use
`/reload` or restart Pi after changing the extension or `.env` file.

## Requirements

Node.js 22.19 or newer, matching Pi's runtime requirement.
