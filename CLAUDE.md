@/home/jake/.dotfiles/AGENTS.md

# Agent orchestration (Subagents and workflows)
opus   = gpt-5.6-sol
sonnet = gpt-5.6-terra
haiku  = gpt-5.6-luna

## Workflows

When explicit effort is requested, never use the bare
haiku/sonnet/opus alias.

Pass the full proxy model ID with effort embedded:

model: "gpt-5.6-luna(medium)"

## Direct subagents

Direct subagents dont currently support the full proxy
model ID nor custom effort levels so only use the bare
haiku/sonnet/opus aliases.
