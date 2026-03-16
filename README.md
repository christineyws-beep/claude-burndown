# claude-burndown

**Your codebase maintains itself while you sleep.**

claude-burndown is an autonomous nightly maintenance tool for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). It scans your projects for no-regret tasks — TODO cleanups, missing error handling, lint fixes, test gaps, dead code — classifies them by risk, and executes the safe ones automatically. You wake up to a clean diff on a branch and a report of what was done.

Every change is on a branch. Every change is tested. Nothing is pushed. If tests fail, changes are reverted. You review in the morning and merge what you like.

---

## What it does

```
$ claude -p /nightly-burndown
```

```
## Nightly Burndown — 2026-03-15

### Will Execute (~47 min total)
1. Add structured logging to adapters (25 min) — my-api
2. Add retry logic with exponential backoff (20 min) — my-api
3. Delete leftover test fixtures (2 min) — my-webapp

### Needs Your Input
- Which auth provider to migrate to? — my-api
- Add pagination to search endpoint? — my-api

### Blocked
- Deploy to staging — waiting for DNS propagation

Proceeding with autonomous tasks...
```

```
## Burndown Complete — 2026-03-15

### Done
- [x] Add structured logging to adapters — my-api (25 min)
- [x] Add retry logic with exponential backoff — my-api (20 min)
- [x] Delete leftover test fixtures — my-webapp (2 min)

### Still Needs Input
- Which auth provider to migrate to? — my-api

---
3 tasks completed | 47 min spent | 55 tests passing
```

## Quick start

### 1. Install

```bash
git clone https://github.com/christineyws-beep/claude-burndown.git
cd claude-burndown
chmod +x install.sh uninstall.sh
./install.sh
```

The installer will:
- Install the `/nightly-burndown` slash command for Claude Code
- Create a config file at `~/.config/claude-burndown/burndown.yaml`
- Optionally set up nightly scheduling (macOS launchd, Linux systemd, or cron)

### 2. Add your projects

Edit `~/.config/claude-burndown/burndown.yaml`:

```yaml
log_dir: ~/burndown-logs
max_execution_minutes: 60

projects:
  - name: my-webapp
    path: ~/code/my-webapp
    exclude: [node_modules, dist, .next]

  - name: my-api
    path: ~/code/my-api
    notes: ~/notes/api-burndown.md     # optional burndown tracker
    exclude: [.venv, __pycache__]
```

### 3. Run it

From within a Claude Code session:
```
/nightly-burndown
```

From the command line:
```bash
claude -p /nightly-burndown
```

Or let it run every night at 10pm — the installer sets this up for you.

---

## Safety model

claude-burndown is built for unattended execution. Safety is enforced at two layers: the prompt (what Claude is instructed to do) and the tool allowlist (what Claude is permitted to do).

| Rule | Enforced by |
|------|------------|
| All changes on branches, never `main` | prompt |
| Revert if tests fail | prompt |
| Never push to any remote | prompt |
| Never deploy anywhere | prompt |
| Never delete files (unless marked safe) | prompt |
| Never add dependencies | prompt |
| Never touch secrets or `.env` files | prompt |
| Never modify CI/CD pipelines | prompt |
| Tool access restricted to file operations | `--allowedTools` flag |

If something unexpected happens, every change is on a `burndown/YYYY-MM-DD` branch:

```bash
git branch -D burndown/2026-03-15   # delete unwanted changes
```

See [docs/SAFETY.md](docs/SAFETY.md) for the full safety model.

---

## How it works

claude-burndown is a [Claude Code slash command](https://docs.anthropic.com/en/docs/claude-code) — a markdown file that Claude interprets as structured instructions. The entire "program" is a prompt. There is no traditional code to execute.

This means:
- **Zero dependencies** beyond Claude Code
- **No build step, no runtime** — it runs inside your existing Claude Code environment
- **Fully customizable** — edit `~/.claude/commands/nightly-burndown.md` to change any behavior
- **Portable** — works on any project in any language

### What it scans for

- `TODO`, `FIXME`, `HACK`, `XXX` comments in source files
- Missing or incomplete tests
- Lint and type errors
- Stale git branches and uncommitted changes
- Outdated dependencies (patch versions only)
- Burndown tracker files (if configured) for pre-classified tasks

### What it considers "autonomous" (safe to execute)

- Adding logging, error handling, or retry logic
- Fixing lint and type errors
- Writing tests for existing code
- Cleaning up resolved TODOs
- Deleting files explicitly marked safe-to-delete
- Updating docs to match current code

### What it flags as "needs input"

- Architecture decisions
- New dependencies
- Deployment
- Anything touching external services or credentials

---

## Scheduling

The installer offers three options:

| Platform | Method | Runs when asleep? |
|----------|--------|-------------------|
| macOS | launchd | Runs on wake |
| Linux | systemd user timer | Yes (if machine is on) |
| Any Unix | cron | Yes (if machine is on) |

See [docs/SCHEDULING.md](docs/SCHEDULING.md) for management commands.

---

## Configuration reference

See [docs/CONFIGURATION.md](docs/CONFIGURATION.md) for the full YAML reference, including safety overrides and project options.

---

## Uninstall

```bash
cd claude-burndown
./uninstall.sh
```

Removes the slash command, scheduling jobs, and optionally the config. Logs are preserved.

---

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and authenticated
- macOS, Linux, or WSL
- git (for branch creation and change tracking)

## Contributing

Contributions welcome. The core of the project is `commands/nightly-burndown.md` — the prompt that drives all behavior. If you find tasks it should handle, safety rules it should enforce, or scanning patterns it misses, open an issue or PR.

## License

MIT
