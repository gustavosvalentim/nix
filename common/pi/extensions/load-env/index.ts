import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { loadEnvFile } from "node:process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export const DEFAULT_ENV_PATH = join(homedir(), ".pi", ".env");

/** Load Pi's optional global environment file into the Pi process. */
export function loadPiEnv(envPath = DEFAULT_ENV_PATH): boolean {
	if (!existsSync(envPath)) return false;

	// Preserve variables explicitly supplied when Pi was launched.
	loadEnvFile(envPath);
	return true;
}

export default function (_pi: ExtensionAPI) {
	loadPiEnv();
}
