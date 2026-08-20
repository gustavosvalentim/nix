import { mkdir, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("save-md", {
    description: "Save the last assistant message (usage: /save-md [path])",
    handler: async (args, ctx) => {
      const branch = ctx.sessionManager.getBranch();
      let markdown: string | undefined;

      for (let i = branch.length - 1; i >= 0; i--) {
        const entry = branch[i];
        if (entry.type !== "message" || entry.message.role !== "assistant") continue;

        markdown = entry.message.content
          .filter((block) => block.type === "text")
          .map((block) => block.text)
          .join("\n\n")
          .trimEnd();
        break;
      }

      if (markdown === undefined) {
        ctx.ui.notify("No assistant message to save", "warning");
        return;
      }

      if (!markdown) {
        ctx.ui.notify("The last assistant message has no text to save", "warning");
        return;
      }

      const requestedPath = args.trim() || "last-agent-message.md";
      const outputPath = resolve(
        ctx.cwd,
        /\.md$/i.test(requestedPath) ? requestedPath : `${requestedPath}.md`,
      );

      try {
        await mkdir(dirname(outputPath), { recursive: true });
        await writeFile(outputPath, `${markdown}\n`, "utf8");
        ctx.ui.notify(`Saved to ${outputPath}`, "info");
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        ctx.ui.notify(`Could not save markdown: ${message}`, "error");
      }
    },
  });
}
