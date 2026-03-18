# Contributing to Claude Burndown

Thanks for your interest in contributing! This project provides slash commands for Claude Code that automate maintenance and development workflows.

## How commands work

Each slash command is a Markdown file in `~/.claude/commands/`. Claude Code reads these files and exposes them as `/command-name`. The file contains:

- **Frontmatter** with a `description` field (shown in command list)
- **Markdown body** with the prompt Claude receives when the command is invoked

```markdown
---
description: What this command does (shown in /help)
---

# Command Name

Instructions for Claude when this command runs...
```

## Adding a new command

1. Create a new `.md` file in `commands/`
2. Add frontmatter with a clear `description`
3. Write the prompt — be specific about inputs, outputs, and safety constraints
4. Test locally by copying to `~/.claude/commands/` and running it
5. Open a PR with the [New Command template](https://github.com/christinebuilds/claude-burndown/issues/new?template=new_command.md)

## Modifying an existing command

1. Read the existing command to understand its intent
2. Make your changes — keep the same style and safety constraints
3. Test locally before submitting
4. Open a PR explaining what changed and why

## Style guidelines

- Commands should be **safe by default** — prefer read-only operations, ask before destructive actions
- Use clear section headers (`## Step 1`, `## Step 2`) for multi-step workflows
- Include guard rails: what the command should NOT do
- Keep prompts focused — one command, one job

## Testing locally

```bash
# Copy your command to the Claude Code commands directory
cp commands/my-command.md ~/.claude/commands/

# Run it in Claude Code
claude
> /my-command
```

## Pull request process

1. Fork the repo and create a feature branch
2. Make your changes with clear commit messages
3. Test the command locally
4. Open a PR — the template will guide you through what to include
5. A maintainer will review and merge

## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). Be kind.
