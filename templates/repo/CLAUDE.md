# CLAUDE.md

This repository is configured with Memento Kit.

## Project Info

- Name: `__PROJECT_NAME__`
- Summary: `__PROJECT_SUMMARY__`
- Stack: `__PROJECT_STACK__`
- Phase: `__PROJECT_PHASE__`
- Deadline: `__PROJECT_DEADLINE__`

## Start Here

1. `README.md`
2. `AGENTS.md`
3. `docs/README.md`
4. `docs/SYSTEM_INTENT.md`
5. `ARCHITECTURE.md`

## File Map

| Need | Open |
| --- | --- |
| collaboration rules | `README.md`, `AGENTS.md` |
| Claude-native layer | `.claude/README.md`, `docs/CLAUDE_COMPATIBILITY.md` |
| runtime context memory | `.agent-context/briefs/`, `.agent-context/handoffs/` |
| architecture map | `ARCHITECTURE.md` |
| system intent | `docs/SYSTEM_INTENT.md` |
| doc router | `docs/README.md` |
| active plans | `docs/exec-plans/active/` |
| surface specs | `docs/product-specs/` |
| generated maps | `docs/generated/` |
| prompts | `prompts/` |

## Context Discipline

- Treat the current git worktree rooted at this repository as the canonical implementation target.
- Do not start in `docs/archive/`.
- Do not treat `.agent-context/` as authority.
- Keep `CLAUDE.md` short; put reusable expert workflows in `.claude/agents/` or `.claude/commands/`.
- Use `ctx:checkpoint` for semantic memory.
- Use `ctx:compact` and `ctx:restore` instead of relying on long chat history.
