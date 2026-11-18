---
name: run-test-plan
description: Execute a test plan checklist and record the results. Works on the `## Test plan` section of a GitHub PR body (ticks passing items in place) or on a Linear issue comment containing a checklist (posts a results comment). Use this skill when the user says "run the test plan", "check off the test plan items", "execute the test plan in this issue", "run the test plan on this PR", or points to a PR or Linear issue with a test plan.
user_invocable: true
---

Execute a structured test plan, then record the results where the plan lives.

## Modes

- **PR mode**: `$ARGUMENTS` contains a GitHub PR number or URL (e.g. `42`, `#42`, `https://github.com/org/repo/pull/42`), or the user asks to run the test plan "on the PR" for the current branch. The plan is the `## Test plan` section of the PR body.
- **Linear mode**: `$ARGUMENTS` contains a Linear issue ID or URL. The plan is a checklist in one of the issue's comments.

If neither is given, check whether the current branch has an open PR (`gh pr view --json number`). Use PR mode if it does; otherwise ask the user for a PR or Linear issue.

## Steps

1. **Locate the test plan.**
   - **PR mode:** run `gh pr view <PR> --json number,body,headRefName,url`. Extract the `## Test plan` section: everything from that heading up to the next `## ` heading or the end of the body. If there is no such section, stop and tell the user. If the section says `Not needed:`, report that and stop.
   - **Linear mode:** use the Linear MCP tools to read the issue and all its comments. Find the comment that contains a markdown checklist (lines starting with `- [ ]` or `- [x]`). If several comments contain checklists, ask the user which one to use.

2. **Parse the test plan.** Extract each checklist item as a distinct test case:
   - `- [ ] <item>`: not yet verified.
   - `- [x] <item>`: already verified. Treat it as passing unless the user asks to re-run everything.

3. **Prepare the environment (PR mode).** Make sure the PR's head branch is checked out locally (`gh pr checkout <PR>` if the current branch differs and the working tree is clean; otherwise stop and ask). The results must reflect the PR's code, not another branch.

4. **Execute each unchecked item.**
   - Read and understand what the test requires: feature behavior, UI state, API response, and so on.
   - Run the appropriate verification:
     - For unit and integration tests, use the project's test command. Auto-detect it from `package.json`, `pnpm-workspace.yaml`, `build.gradle`, `Package.swift` or `Makefile`, or follow the project's CLAUDE.md if it names one.
     - For build checks, run `npm run build`, `pnpm build` or the equivalent.
     - For code-level checks, read the relevant files and verify the behavior is implemented.
     - For manual or UI steps (preview deployments, devices, third-party dashboards, browser extensions on live sites), do not attempt them. Mark them **Requires manual verification**.
   - Record the result: **Pass**, **Fail**, or **Requires manual verification**.
   - For failures, capture the error output or reason.

5. **Record the results.**
   - **PR mode:**
     - Rewrite only the `## Test plan` section of the PR body. Every other part of the body stays byte-for-byte unchanged.
     - **Pass:** change `- [ ]` to `- [x]` and append ` — ✅ <one-line evidence, e.g. the command run and its result>`.
     - **Fail:** leave `- [ ]` and append ` — ❌ <short reason>`.
     - **Manual:** leave `- [ ]` and append ` — ⚠️ Manual: <what the tester should do>`, unless the item already spells out the steps.
     - Don't add duplicate notes to an item that already has one from an earlier run. Replace the old note instead.
     - Write the new body to a temporary file and run `gh pr edit <PR> --body-file <file>`.
     - Post a PR comment (`gh pr comment <PR> --body-file <file>`) with the summary line and the list of failed items.
   - **Linear mode:**
     - Post a new comment on the issue with the Linear MCP `save_comment` tool. Never edit the original test plan comment.
     - Use this format:
     ```
     ## Test Plan Results

     - [x] <item> — ✅ Pass
     - [ ] <item> — ❌ Fail: <error summary>
     - [ ] <item> — ⚠️ Requires manual verification

     **Summary**: N passed, N failed, N require manual verification.
     ```

6. **Report to the user.** Give the pass, fail and manual counts. Link the PR (PR mode) or the Linear comment (Linear mode). List the manual items that still need a person.

## Notes
- Never mark a test as passing without actually running or verifying it.
- Never tick a manual item. Only the person who performed it may tick it.
- If a test fails, include enough detail (error message, file, line) for the developer to reproduce and fix it.
- In PR mode, re-read the PR body immediately before editing, so you don't overwrite changes someone made while the tests were running.
