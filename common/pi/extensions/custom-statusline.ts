import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { relative, resolve, sep } from "node:path";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type Usage = {
  input?: number;
  output?: number;
  cost?: { total?: number };
};

function formatTokens(count: number): string {
  if (count < 1_000) return String(count);
  if (count < 10_000) return `${(count / 1_000).toFixed(1)}k`;
  if (count < 1_000_000) return `${Math.round(count / 1_000)}k`;
  if (count < 10_000_000) return `${(count / 1_000_000).toFixed(1)}M`;
  return `${Math.round(count / 1_000_000)}M`;
}

function formatDirectory(cwd: string): string {
  const home = resolve(homedir());
  const directory = resolve(cwd);
  const fromHome = relative(home, directory);
  const insideHome =
    fromHome === "" ||
    (fromHome !== ".." && !fromHome.startsWith(`..${sep}`));

  if (!insideHome) return cwd;
  return fromHome === "" ? "~" : `~${sep}${fromHome}`;
}

function getUsage(ctx: ExtensionContext): { input: number; output: number; cost: number } {
  let input = 0;
  let output = 0;
  let cost = 0;

  const add = (usage?: Usage) => {
    if (!usage) return;
    input += usage.input ?? 0;
    output += usage.output ?? 0;
    cost += usage.cost?.total ?? 0;
  };

  for (const entry of ctx.sessionManager.getEntries()) {
    if (entry.type === "message") {
      if (entry.message.role === "assistant" || entry.message.role === "toolResult") {
        add(entry.message.usage);
      }
    } else if (entry.type === "branch_summary" || entry.type === "compaction") {
      add(entry.usage);
    }
  }

  return { input, output, cost };
}

function getDirectoryText(
  ctx: ExtensionContext,
  branch: string | null,
  prNumber: number | undefined,
): string {
  const git = branch
    ? ` (${branch}${prNumber === undefined ? "" : ` #${prNumber}`})`
    : "";
  return formatDirectory(ctx.cwd) + git;
}

function getContextText(ctx: ExtensionContext): string {
  const context = ctx.getContextUsage();
  const used = context?.tokens == null ? "?" : formatTokens(context.tokens);
  const total = formatTokens(
    context?.contextWindow ?? ctx.model?.contextWindow ?? 0,
  );
  return `ctx ${used}/${total}`;
}

function getUsageText(ctx: ExtensionContext): string {
  const usage = getUsage(ctx);
  return `↑${formatTokens(usage.input)} ↓${formatTokens(usage.output)} $${usage.cost.toFixed(3)}`;
}

function getModelText(ctx: ExtensionContext): string {
  if (!ctx.model) return "no model";
  const reasoning = ctx.model.reasoning
    ? (ctx.thinkingLevel ?? "off")
    : "no reasoning";
  return `(${ctx.model.provider}) ${ctx.model.id} - ${reasoning}`;
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    let prNumber: number | undefined;
    let disposed = false;
    let lookupGeneration = 0;

    ctx.ui.setFooter((tui, theme, footerData) => {
      const refreshPrNumber = () => {
        const generation = ++lookupGeneration;
        prNumber = undefined;
        tui.requestRender();

        execFile(
          "gh",
          ["pr", "view", "--json", "number", "--jq", ".number"],
          { cwd: ctx.cwd, timeout: 5_000 },
          (error, stdout) => {
            if (disposed || generation !== lookupGeneration) return;
            const parsed = Number.parseInt(stdout.trim(), 10);
            prNumber = !error && Number.isFinite(parsed) ? parsed : undefined;
            tui.requestRender();
          },
        );
      };

      const unsubscribe = footerData.onBranchChange(refreshPrNumber);
      refreshPrNumber();

      return {
        dispose() {
          disposed = true;
          lookupGeneration++;
          unsubscribe();
        },
        invalidate() {},
        render(width: number): string[] {
          const ellipsis = theme.fg("dim", "…");
          const directoryLine = truncateToWidth(
            theme.fg(
              "dim",
              getDirectoryText(ctx, footerData.getGitBranch(), prNumber),
            ),
            width,
            ellipsis,
          );
          const left = theme.fg(
            "dim",
            `${getUsageText(ctx)} ${getContextText(ctx)}`,
          );
          const right = theme.fg("dim", getModelText(ctx));
          const minimumGap = 2;

          if (
            visibleWidth(left) + minimumGap + visibleWidth(right) <=
            width
          ) {
            const padding = " ".repeat(
              width - visibleWidth(left) - visibleWidth(right),
            );
            return [directoryLine, left + padding + right];
          }

          return [
            directoryLine,
            truncateToWidth(left, width, ellipsis),
            truncateToWidth(right, width, ellipsis),
          ];
        },
      };
    });
  });
}
