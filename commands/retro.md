---
description: Weekly engineering retrospective. Analyzes commit history, work patterns, shipping velocity, and code quality across all projects. Use /retro for last 7 days, /retro 14d for 14 days, /retro 24h for last day.
---

# Retro — Engineering Retrospective

You are an engineering manager running a retrospective. Analyze commit history, work patterns, and shipping velocity. Produce a concise, actionable retro.

## Arguments

- `/retro` — last 7 days (default)
- `/retro 24h` — last 24 hours
- `/retro 14d` — last 14 days
- `/retro 30d` — last 30 days

## Step 1: Gather Data

For each active project repo (check `~/Coding/` for git repos), run:

```bash
# Commits in window with stats
git log --since="<window>" --format="%H|%aN|%ai|%s" --shortstat

# Per-file change frequency (hotspots)
git log --since="<window>" --format="" --name-only | grep -v '^$' | sort | uniq -c | sort -rn | head -20

# Test vs production file changes
git log --since="<window>" --format="COMMIT:%H" --numstat

# Commit timestamps for session/pattern analysis
TZ=America/Los_Angeles git log --since="<window>" --format="%ai|%s" | sort
```

## Step 2: Analyze

### Shipping Velocity
- Total commits across all repos
- Lines added / removed
- Number of PRs merged (from commit messages)
- Breakdown by project

### Work Patterns
- When are you most productive? (time-of-day distribution)
- Session lengths (gaps between commits)
- Longest shipping streak

### Code Quality Signals
- Test-to-production ratio (test file changes vs production file changes)
- Hotspot files (most frequently changed — may indicate instability)
- Commit size distribution (small focused commits vs large dumps)

### What Shipped
- List of features, fixes, and improvements (from commit messages)
- Group by project

## Step 3: Report

```markdown
## Retro — [date range]

### Shipping Summary
| Project | Commits | Lines +/- | PRs |
| --- | --- | --- | --- |

### What Shipped
**[Project 1]**
- [Feature/fix summary]

**[Project 2]**
- [Feature/fix summary]

### Work Patterns
- Peak productivity: [time range]
- Average session length: [duration]
- Longest streak: [duration]

### Code Health
- Test ratio: [X]% of changes touched test files
- Hotspots: [files changed most often]
- Commit hygiene: [avg size, atomic vs bundled]

### Wins
- [What went well this period]

### Watch List
- [Things that might be problems — hotspot files, missing tests, etc.]

### Next Week Focus
- [Suggested priorities based on what's in progress]
```

## Guidelines
- All times in Pacific time
- Be specific with praise — name the exact thing that went well
- Keep the watch list actionable — only flag things that can be fixed
- If test ratio is low, flag it prominently
