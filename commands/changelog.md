---
description: Auto-generate user-friendly changelogs from git commits. Transforms technical commits into clear release notes grouped by category. Use /changelog before a release, or /changelog 7d for a weekly summary.
---

# Changelog Generator

Transform technical git commits into polished, user-friendly changelogs.

## Arguments

- `/changelog` — commits since last tag/release
- `/changelog 7d` — last 7 days
- `/changelog 14d` — last 14 days
- `/changelog v1.0.0..v1.1.0` — between two tags
- `/changelog since:2026-03-01` — since a specific date

## Step 1: Gather Commits

```bash
# Detect last tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

# Get commits based on argument
git log ${LAST_TAG:+$LAST_TAG..HEAD} --format="%h|%aN|%s" --no-merges
```

## Step 2: Categorize

Read each commit message and classify:

| Category | Commit patterns | Icon |
| --- | --- | --- |
| **New Features** | `feat:`, `add:`, "Add", "New", "Implement" | ✨ |
| **Improvements** | `improve:`, `enhance:`, "Update", "Improve", "Optimize" | 🔧 |
| **Bug Fixes** | `fix:`, "Fix", "Resolve", "Correct" | 🐛 |
| **Breaking Changes** | `BREAKING:`, `!:`, "Remove", "Drop support" | ⚠️ |
| **Security** | `security:`, "CVE", "vulnerability" | 🔒 |
| **Documentation** | `docs:`, "README", "doc" | 📝 |
| **Internal** | `chore:`, `refactor:`, `test:`, `ci:`, "Merge" | (excluded from user-facing) |

## Step 3: Translate to User Language

For each non-internal commit:
1. Strip conventional commit prefixes (`feat:`, `fix:`, etc.)
2. Rewrite in user-facing language — what changed for the user, not what changed in the code
3. Group related commits (e.g., multiple commits for one feature → one entry)

**Translation rules:**
- "Add GBIF adapter" → "Added support for GBIF — access 2.8B+ global biodiversity records"
- "Fix NEON portal URLs" → "Fixed broken links to NEON data portal"
- "Refactor query handler" → *(skip — internal)*

## Step 4: Format

```markdown
# Changelog

## [version or date range]

### ✨ New Features
- **[Feature name]**: [User-facing description]

### 🔧 Improvements
- **[Improvement]**: [What's better for the user]

### 🐛 Bug Fixes
- [What was broken and is now fixed]

### ⚠️ Breaking Changes
- [What changed and what users need to do]

### 🔒 Security
- [What was patched]
```

## Step 5: Output Options

Ask the user:
- **A)** Append to `CHANGELOG.md` in the project
- **B)** Output here only (for copy-pasting into a GitHub release, Substack post, etc.)
- **C)** Both

If appending to CHANGELOG.md, prepend the new entry at the top (newest first).

## Guidelines

- Exclude merge commits and internal refactors from user-facing changelog
- Group related commits into single entries (don't list 5 commits for one feature)
- Write for the user, not the developer — "you can now..." not "implemented handler for..."
- Keep entries concise — one line each unless a feature needs explanation
- Include contributor attribution if multiple authors
- For data-heavy projects: mention data source names and record counts when relevant
