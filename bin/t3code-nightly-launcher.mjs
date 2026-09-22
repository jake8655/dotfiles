import { spawn } from "node:child_process";
import { existsSync } from "node:fs";
import { isAbsolute } from "node:path";

const npxPath = "/home/jake/.vite-plus/bin/npx";
const shutdownGraceMs = 5_000;

let activeChild = null;
let stoppingSignal = null;
let forceKillTimer = null;

function signalProcess(pid, signal) {
  try {
    process.kill(pid, signal);
  } catch (error) {
    if (error?.code !== "ESRCH") throw error;
  }
}

function signalProcessGroup(pid, signal) {
  signalProcess(-pid, signal);
}

function stop(signal) {
  if (stoppingSignal !== null) return;
  stoppingSignal = signal;

  const target = activeChild;
  if (target === null) return;

  if (target.kind === "server") {
    // Let T3 coordinate its own provider and agent shutdown first.
    signalProcess(target.process.pid, signal);
  } else {
    // npm has no application state to preserve during package resolution.
    signalProcessGroup(target.process.pid, signal);
  }

  forceKillTimer = setTimeout(() => {
    signalProcessGroup(target.process.pid, "SIGKILL");
  }, shutdownGraceMs);
}

process.once("SIGTERM", () => stop("SIGTERM"));
process.once("SIGINT", () => stop("SIGINT"));

function waitForExit(child) {
  return new Promise((resolve, reject) => {
    child.once("error", reject);
    child.once("exit", (code, signal) => resolve({ code, signal }));
  });
}

async function resolveNightlyEntrypoint() {
  const child = spawn(
    npxPath,
    [
      "--yes",
      "--package=t3@nightly",
      "--",
      "sh",
      "-c",
      'readlink -f "$(command -v t3)"',
    ],
    {
      detached: true,
      stdio: ["ignore", "pipe", "inherit"],
    },
  );

  activeChild = { kind: "resolver", process: child };
  let stdout = "";
  child.stdout.setEncoding("utf8");
  child.stdout.on("data", (chunk) => {
    stdout += chunk;
    if (stdout.length > 1024 * 1024) {
      signalProcessGroup(child.pid, "SIGKILL");
    }
  });

  const result = await waitForExit(child);
  if (activeChild?.process === child) activeChild = null;

  if (stoppingSignal !== null) return null;
  if (result.code !== 0) {
    throw new Error(`Could not resolve t3@nightly (exit ${String(result.code)}).`);
  }

  const entrypoint = stdout.trim().split(/\r?\n/).at(-1);
  if (!entrypoint || !isAbsolute(entrypoint) || !existsSync(entrypoint)) {
    throw new Error(`Invalid t3@nightly entrypoint: ${String(entrypoint)}`);
  }
  return entrypoint;
}

async function main() {
  const entrypoint = await resolveNightlyEntrypoint();
  if (entrypoint === null || stoppingSignal !== null) return;

  const child = spawn(process.execPath, [entrypoint, "serve"], {
    detached: true,
    stdio: "inherit",
  });
  activeChild = { kind: "server", process: child };

  // Cover a signal arriving between package resolution and server spawn.
  if (stoppingSignal !== null) stop(stoppingSignal);

  const result = await waitForExit(child);
  if (activeChild?.process === child) activeChild = null;
  if (forceKillTimer !== null) clearTimeout(forceKillTimer);

  // Reap any provider/tool descendants that survived the server process.
  signalProcessGroup(child.pid, "SIGKILL");

  if (stoppingSignal === null && result.code !== 0) {
    process.exitCode = result.code ?? 1;
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
