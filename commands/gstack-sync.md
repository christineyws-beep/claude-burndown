---
description: Check gstack repo for new or updated skills, compare against our commands, and report what's changed. Run weekly to stay current. Use /gstack-sync to check for updates.
---

# gstack Sync — Weekly Upstream Check

Check the gstack repo (github.com/garrytan/gstack) for new or updated skills, and compare against our local commands.

**IMPORTANT: This is a lightweight diff check. Do NOT use Explore agents or WebFetch. Use only `gh api` and local file reads.**

## Step 1: Early exit check

Run this first:
```bash
# Check latest commit date
LAST_COMMIT=$(gh api repos/garrytan/gstack/commits --jq '.[0].commit.committer.date' 2>/dev/null)
echo "Latest gstack commit: $LAST_COMMIT"
```

Read the SHA cache at `~/.claude/gstack-sha-cache.json`. If it exists and the latest commit date is before our last sync, report "No changes since last sync" and stop.

## Step 2: Fetch gstack state (3 API calls only)

Run all three in parallel:
```bash
# 1. Recent commits (one-liners only)
gh api repos/garrytan/gstack/commits --jq '.[0:10] | .[] | .commit.committer.date[:10] + " " + (.commit.message | split("\n")[0])' 2>/dev/null
```

```bash
# 2. List all top-level directories (skill names)
gh api repos/garrytan/gstack/contents --jq '[.[] | select(.type=="dir") | .name] | sort | .[]' 2>/dev/null
```

```bash
# 3. Get VERSION
gh api repos/garrytan/gstack/contents/VERSION --jq '.content' 2>/dev/null | base64 -d
```

## Step 3: Compare against our commands

Our commands (hard-coded mapping — update if we add/remove commands):

| gstack skill | Our command | Status |
| --- | --- | --- |
| `plan-ceo-review` | `/plan ceo` | Integrated as mode |
| `plan-design-review` | `/plan design` | Integrated as mode |
| `plan-eng-review` | `/plan eng` | Integrated as mode |
| `design-consultation` | `/design-consultation` | Adapted |
| `review` | `/review` (built-in) | Built-in skill |
| `ship` | `/ship` | Adapted |
| `qa` | `/qa` | Adapted |
| `qa-only` | `/qa-only` | Adapted |
| `qa-design-review` | `/qa-design` | Adapted |
| `browse` | `webapp-testing` (built-in) | Different approach |
| `setup-browser-cookies` | `/setup-browser-cookies` | Adapted |
| `retro` | `/retro` | Adapted |
| `document-release` | `/document-release` | Adapted |
| `gstack-upgrade` | `/gstack-sync` | We check upstream |

Our extras (not in gstack): `/security-check`, `/nightly-burndown`, `/gstack-sync`, `/api-review`, `/changelog`, `/red-team`, `/threat-model`, `/plan`

Compare the gstack directory listing from Step 2 against the left column above. Any directory NOT in the table is a **new skill**.

## Step 4: Check SHAs for updated skills

Only for skills that exist in both — fetch their SKILL.md SHA and compare to cached values:
```bash
# For each mapped gstack skill, get the SKILL.md SHA
# Run as a single command to minimize API calls
for skill in design-consultation qa qa-only qa-design-review retro document-release ship setup-browser-cookies browse plan-ceo-review plan-design-review plan-eng-review review gstack-upgrade; do
  SHA=$(gh api "repos/garrytan/gstack/contents/$skill/SKILL.md" --jq '.sha' 2>/dev/null)
  echo "$skill:$SHA"
done
```

Compare each SHA against `~/.claude/gstack-sha-cache.json`. If a SHA changed, that skill was updated — fetch its SKILL.md content to see what changed:
```bash
gh api "repos/garrytan/gstack/contents/<skill-name>/SKILL.md" --jq '.content' | base64 -d
```

Only fetch content for skills whose SHA actually changed. If no SHAs changed, skip this entirely.

## Step 5: Update SHA cache

Write the current SHAs to `~/.claude/gstack-sha-cache.json`:
```json
{
  "last_sync": "2026-03-18",
  "last_commit": "<latest commit date>",
  "shas": {
    "design-consultation": "<sha>",
    "qa": "<sha>",
    ...
  }
}
```

## Step 6: Report

```markdown
## gstack Sync — [date]

### gstack Version: [version]
### Last checked: [date]

### New Skills Found
- [skill name] — [what it does] — **Recommend: integrate / skip / watch**
(or "None")

### Updated Skills
- [skill name] — [what changed] — **Recommend: update / no action**
(or "None — all SHAs match")

### No Action Needed
- All [N] mapped skills are current
```

## Step 7: Create Task (only if actionable)

If there are new or updated skills, create a Google Tasks item:
- Title: `gstack sync: [N] updates found — [date]`
- Notes: Summary of what's new and recommendations

If no changes, skip task creation.

## Step 8: Update memory

Update the `last_sync` date in the reference memory file at:
`~/.claude/projects/-Users-cs-Coding/memory/reference_gstack_sync.md`
