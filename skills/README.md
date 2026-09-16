# Agent skills

`doska/` contains a portable Agent Skills package for working directly with a Doska board's local Markdown files. It does not require MCP. The default board directory is `<project>/.kanban/`.

## Install

From this repository, copy the complete skill directory to a location your agent loads. For agents that support `.agents/skills/`, install it in a target project:

```sh
mkdir -p /path/to/project/.agents/skills
cp -R skills/doska /path/to/project/.agents/skills/
```

Or install it for all projects in an agent that supports the shared user directory:

```sh
mkdir -p ~/.agents/skills
cp -R skills/doska ~/.agents/skills/
```

For Claude Code, use `.claude/skills/` in the target project or `~/.claude/skills/` for all projects instead. Check for an existing `doska` skill before copying so you do not overwrite local changes. Reload your agent after installation.

In the Doska desktop app, select the target project's `.kanban/` directory as the board's local sync folder. Keep the skill outside that directory. The desktop app must run for file changes to sync with the board.

Example request:

> Use the doska skill to move the release checklist to the Done column in .kanban/.

## Maintenance

The installed skill is self-contained. Its file rules come from `packages/vault/src/`, especially `card-file.ts`, `column-folder.ts`, `folders.ts`, `trash.ts`, and `vault.ts`. Check those rules when the local sync format changes.
