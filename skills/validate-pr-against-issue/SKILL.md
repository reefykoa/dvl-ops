---
name: validate-pr-against-issue
description: Compare a Linear issue against a GitHub PR and report which requirements are implemented, partially implemented, or missing. Use this skill when the user says "validate this PR against its Linear issue", "check the PR covers the issue", or wants a scope/acceptance gap report.
user_invocable: true
---

Compare a Linear issue's requirements against a GitHub PR and produce a gap report.

## Steps

1. **Gather context.** If not provided in `$ARGUMENTS`, prompt the user for:
   - The Linear issue URL or issue ID (e.g., `SW-27`).
   - The GitHub PR URL or PR number.

2. **Fetch the Linear issue.** Use the Linear MCP tool or `linear_get_issue` to retrieve:
   - Issue title and description.
   - All comments on the issue (for additional context or acceptance criteria).
   - Assignee display name.

3. **Fetch the GitHub PR.** Run:
   ```
   gh pr view <PR_NUMBER> --json title,body,files,commits
   gh pr diff <PR_NUMBER>
   ```
   Collect: PR title, description, changed files, and full diff.

4. **Extract requirements from the issue.** Parse the issue description and comments for:
   - Explicit acceptance criteria (checkboxes, numbered lists, "must", "should" language).
   - Implicit requirements stated in the problem description.
   - Any sub-tasks or linked issues mentioned.

5. **Map each requirement to the PR diff.** For each requirement, determine:
   - **Implemented** — the diff contains code that directly fulfills this requirement.
   - **Partially implemented** — some work exists but it's incomplete (e.g., backend done, frontend missing; happy path covered but error handling missing).
   - **Missing** — no corresponding change found in the diff.

6. **Produce the gap report.** Format:
   ```
   ## PR Validation: <ISSUE_ID> → PR #<PR_NUMBER>

   ### Implemented
   - [requirement] — [files/lines that implement it]

   ### Partially Implemented
   - [requirement] — [what's done] / [what's missing]

   ### Missing
   - [requirement] — [no corresponding change found]

   ### Notes
   [Any ambiguities, out-of-scope items, or suggestions]
   ```

7. **Post the report to Linear.** Post the gap report as a comment on the Linear issue using the Linear MCP tool or `./scripts/linear-workflow/post_linear_comment.sh` if available in the current project.

## Notes
- This skill is for scope and acceptance validation, not code style review.
- If a requirement is ambiguous, note the ambiguity rather than guessing.
- Out-of-scope changes in the PR (beyond the issue) should be flagged in the Notes section.
