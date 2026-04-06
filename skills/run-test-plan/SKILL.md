---
name: run-test-plan
description: Read a Linear issue comment containing a test plan checklist, execute each test item, and post an updated comment marking checkboxes as checked (pass) or unchecked (fail) with a brief result note per item. Use this skill when the user says "run the test plan", "check off the test plan items", "execute the test plan in this issue", or points to a Linear issue with a test plan comment.
user_invocable: true
---

Execute a structured test plan from a Linear issue comment, then post the results back to the issue.

## Steps

1. **Gather context.** If not provided in `$ARGUMENTS`, prompt the user for:
   - The Linear issue URL or issue ID containing the test plan.
   - The comment ID or a description to locate the test plan comment (if the issue has multiple comments).

2. **Fetch the issue and locate the test plan comment.**
   Use the Linear MCP tools to read the issue and all its comments. Find the comment that contains a markdown checklist (lines starting with `- [ ]` or `- [x]`). If multiple comments contain checklists, ask the user which one to use.

3. **Parse the test plan.** Extract each checklist item as a distinct test case:
   - `- [ ] <item>` — not yet run.
   - `- [x] <item>` — already marked passing (treat as already verified unless the user asks to re-run).

4. **Execute each test item.** For each unchecked item:
   - Read and understand what the test requires (feature behavior, UI state, API response, etc.).
   - Run the appropriate verification:
     - For unit/integration tests: use the project's test command (auto-detect from `package.json`, `build.gradle`, `Package.swift`, `Makefile`).
     - For build checks: run `npm run build` or equivalent.
     - For code-level checks: read the relevant files and verify the behavior is implemented.
     - For manual/UI steps: note that these cannot be automated and mark them as **Requires manual verification**.
   - Record the result: **Pass**, **Fail**, or **Requires manual verification**.
   - For failures, capture the error output or reason.

5. **Post the results as a Linear comment.**
   Use the Linear MCP `save_comment` tool to post a new comment on the issue with:
   - The updated checklist (checked = pass, unchecked = fail or manual).
   - A brief result note after each item explaining the outcome.

   Format:
   ```
   ## Test Plan Results

   - [x] <item> — ✅ Pass
   - [x] <item> — ✅ Pass
   - [ ] <item> — ❌ Fail: <error summary>
   - [ ] <item> — ⚠️ Requires manual verification

   **Summary**: N passed, N failed, N require manual verification.
   ```

6. **Report to the user** with the final pass/fail counts and the Linear comment URL.

## Notes
- Do not modify the original test plan comment — always post results as a new comment.
- Never mark a test as passing without actually running or verifying it.
- For items that are purely manual (e.g., "verify on device", "check in browser"), mark them as requiring manual verification and describe what the tester should check.
- If a test fails, include enough detail (error message, file, line) for the developer to reproduce and fix it.
