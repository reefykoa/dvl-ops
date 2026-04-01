---
name: fix-unit-tests
description: Run unit tests, fix all failures, and loop until every test passes. Use this skill when unit tests are failing locally or from a CI run, or when the user says "fix the failing tests", "get the tests green", "fix unit test failures", or "keep fixing tests until they pass". Different from fix-ci which addresses GitHub Actions pipeline configuration failures — this skill fixes the actual test and source code.
user_invocable: true
---

Run unit tests, fix failures, and repeat until all tests pass.

## Step 1 — Gather inputs

Use `AskUserQuestion` to ask: "What command runs the unit tests? (e.g. `npm test`, `./gradlew test`, `swift test`, `pytest`) — leave blank to auto-detect."

Use `AskUserQuestion` to ask: "Paste any failing test output or a CI run URL to start from — or leave blank to run tests fresh."

If the test command is blank, auto-detect by checking for these files in order:
- `package.json` → use `npm test`
- `build.gradle` or `build.gradle.kts` → use `./gradlew test`
- `Package.swift` → use `swift test`
- `requirements.txt` or `pyproject.toml` → use `pytest`
- `Makefile` → use `make test`

If none found, stop and ask the user to provide the command.

## Step 2 — Get the initial failure list

**If a CI run URL was provided:**
- Extract the run ID from the URL
- Run `gh run view <RUN_ID> --log-failed` to download the failure logs
- Parse the output to identify each failing test and error message

**If test output was pasted:**
- Parse it directly to identify each failing test name, file path, and error message

**If blank:**
- Run the test command and capture stdout + stderr
- If all tests pass already, report "All tests are passing — nothing to fix." and stop

## Step 3 — Fix each failure

For each failing test:

1. Identify the test file and the source file(s) it exercises from the error output
2. Read the test file to understand what the test expects
3. Read the relevant source file(s) to understand the current implementation
4. Determine whether the fix belongs in:
   - **The source code** — the implementation is wrong and the test expectation is correct
   - **The test** — the test expectation is wrong (e.g. outdated after an intentional API change); only fix the test if the change was intentional
5. Apply the fix

## Step 4 — Rerun and loop

Run the test command again.

- If all tests pass: go to Step 5.
- If there are still failures: return to Step 3 for the remaining failures.
- **Loop limit:** If the same test fails 3 consecutive fix attempts without progress, stop and report the blocker to the user rather than looping indefinitely.

## Step 5 — Report results

Print a summary:
- Which tests were failing and what was fixed in each case
- All files modified (test files and source files separately)
- A reminder: "Changes are NOT committed. Review the diffs and commit when ready."

## Rules

- Never skip a failing test by commenting it out or marking it as `skip`/`pending`/`xit` unless the test is demonstrably incorrect and you explicitly call this out for the user to confirm.
- Only modify the files needed to fix the failing tests — do not refactor, reformat, or clean up passing code.
- Read files before editing them — never apply a fix blind.
- If a fix would require a large architectural change that is out of scope, stop and explain what is needed instead of making a partial change that breaks more tests.
- Do not commit changes. This skill stops after fixes are applied and verified.
