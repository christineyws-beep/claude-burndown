---
description: Run an API contract health check for the current project. Executes the full test suite, compares against the last run, and flags any new failures as upstream API contract breaks. Use /api-health after code changes, or let it run weekly via launchd on Sundays at 2am PT.
---

# API Health Check

You are running an API contract health check for the current project. Your job is to run the full test suite against live APIs, compare results to the previous run, and report any regressions that signal upstream API contract breaks.

---

## Step 0 — Setup

1. Ensure you are working in the project root directory.
2. Create the log directory if it does not exist:
   ```bash
   mkdir -p ./api-health-logs
   ```
3. Determine today's date for the log filename (`YYYY-MM-DD`).

---

## Step 1 — Check for Previous Results

Look for the most recent log in `./api-health-logs/`. Read it to extract:
- The list of **passing** tests
- The list of **failing** tests
- The date of the last run

If no previous log exists, treat all tests as "first run" (no regression comparison possible).

---

## Step 2 — Check for Code Changes

Run `git log --oneline -5` in the project directory to see if any code has changed since the last health check. Record whether there have been code changes — this is critical for interpreting failures:

- **Failures with no code change** = upstream API contract break
- **Failures with code change** = possibly our fault, needs investigation

---

## Step 3 — Run the Test Suite

Execute the full test suite:

```bash
# Adjust the test command for your project's test runner
pytest -v 2>&1
```

Capture the full output. Parse the results to extract:
- Total tests run
- Tests passed (with names)
- Tests failed (with names and failure reasons)
- Tests skipped (with names)
- Total duration

---

## Step 4 — Compare Against Last Run

Compare current results with the previous run from Step 1:

### New Failures (regressions)
Tests that **passed last time** but **fail now**. Classify each:
- **API Contract Break** — no code changed since last run, so the upstream API changed behavior
- **Code Regression** — code changed since last run, failure may be our fault

### Recovered Tests
Tests that **failed last time** but **pass now**.

### Persistent Failures
Tests that **failed last time** and **still fail**.

### New Tests
Tests that appear in this run but not in the previous run.

---

## Step 5 — Write the Log

Save a report to `./api-health-logs/YYYY-MM-DD.md` with this format:

```markdown
# API Health Check — YYYY-MM-DD

**Run time:** HH:MM:SS
**Code changes since last run:** Yes/No
**Last run:** YYYY-MM-DD

## Summary
- Total: X tests
- Passed: X | Failed: X | Skipped: X

## New Failures (API Contract Breaks)
> Tests that passed last time but fail now with NO code changes.
> These indicate the upstream API changed its contract.

- `test_name` — adapter: [adapter name] — error: [brief error]

## New Failures (Code Regressions)
> Tests that passed last time but fail now WITH code changes.

- `test_name` — error: [brief error]

## Recovered
> Tests that failed last time but pass now.

- `test_name` — adapter: [adapter name]

## Persistent Failures
> Tests that failed last time and still fail.

- `test_name` — adapter: [adapter name] — error: [brief error]

## All Passing (X)
<collapsed list of all passing test names>

## Raw Output
<full pytest output>
```

---

## Step 6 — Report

Present a clean summary to the user:

```
## API Health — YYYY-MM-DD

Passed: X/Y | Failed: Z | Skipped: W

### Action Required
- [API CONTRACT BREAK] test_name — OBIS API now returns 404 on /occurrence endpoint
- [REGRESSION] test_name — likely caused by commit abc1234

### Recovered (good news)
- test_name now passes again

### Persistent (known issues)
- test_name — still failing since YYYY-MM-DD
```

If there are **no new failures**, report a clean bill of health:

```
## API Health — YYYY-MM-DD

All X tests passing. No regressions detected.
Last run: YYYY-MM-DD (also clean)
```

---

## Error Handling

- If `uv` is not installed or the project is missing, report the error and exit
- If the test suite hangs (> 10 minutes), note the timeout in the log
- If individual tests timeout, still capture results for tests that did complete
- Always write a log file, even if the run was partial
