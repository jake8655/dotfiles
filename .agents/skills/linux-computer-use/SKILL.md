---
name: linux-computer-use
description: "Use when the user requests Linux Computer Use, the host desktop, their real Linux desktop, or interaction with currently open host windows through screenshots, keyboard, or mouse."
---

# Linux Computer Use

Control the user's real Linux desktop through the `linux-computer-use` MCP
server. This surface observes and interacts with the host session: its current
windows, focus, screenshots, pointer, and keyboard input.

The MCP server supplies the capabilities. This skill only selects the correct
surface and describes how to use those tools safely and reliably.

## Exclusive Routing Boundary

Use this skill when the user says **Linux Computer Use**, **host desktop**,
**real desktop**, **my desktop**, or asks to operate their currently open Linux
applications or windows.

Once selected, use only tools belonging to the configured
`linux-computer-use` MCP server for desktop interaction. Hosts may normalize
hyphens in the server namespace.

- If this MCP is unavailable or an operation fails, report that exact failure.
  Do not silently switch surfaces.
- Do not interpret the general existence of a GUI task as permission to choose
  an isolated workspace.

## Workflow

1. Begin each Computer Use turn with `get_app_state`.
2. Use `doctor` when the user requests a readiness check or diagnostics are
   needed.
3. Before targeted keyboard input, use `list_windows` and `focused_window` to
   identify and verify the host target.
4. Use `screenshot` when visual state is needed, then use the smallest relevant
   action tool such as `activate_window`, `click`, `scroll`, `press_key`,
   `type_text`, or `set_value`.
5. Re-observe after actions when the next step depends on the resulting state.

## Boundaries

- Do not install packages, change portal configuration, or alter desktop setup
  unless the user explicitly requests setup or a fix.
