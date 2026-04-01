---
name: address-review-feedback
description: Read a specific GitHub PR review comment, apply code fixes for high-priority concerns, and post a reply summarizing what was fixed, deferred, or skipped. Use this skill when the user says "address the review feedback", "fix the review comments", or wants to respond to a PR review.
user_invocable: true
---

Read a specific GitHub PR review comment, apply targeted fixes, and post a reply summarizing every feedback item.

## Steps

1. **Gather context.** If not provided in `$ARGUMENTS`, prompt the user for:
   - The PR URL or PR number.
   - The review comment URL or review ID to address.

2. **Fetch the review comment.** Run:
   ```
   gh api <review-comment-url-path>
   ```
   Parse the full comment body. List every distinct feedback item.

3. **Categorize each item.**
   - **High priority**: correctness bugs, security issues, broken contracts, missing tests for critical paths.
   - **Medium priority**: naming, code clarity, minor refactors, style inconsistencies that affect readability.
   - **Low priority**: nitpicks, stylistic preferences, optional suggestions.

4. **Apply fixes.**
   - **High-priority items**: read the relevant file(s) first, then apply a targeted fix. Never apply a fix blind.
   - **Medium-priority items**: apply straightforward fixes. If a fix would require significant refactoring or touches architectural decisions, defer it with an explanation.
   - **Low-priority items**: acknowledge them in the reply without making code changes.
   - Do not apply a fix that would break existing tests or cause a regression. Defer with an explanation instead.

5. **Commit and push fixes.**
   - Stage only the files modified for the fixes.
   - Write a commit message referencing the review (e.g., "address review feedback from PR #<N>").
   - Push the current branch.

6. **Post a reply comment.** Run:
   ```
   gh pr comment <PR_NUMBER> --body "..."
   ```
   The reply must cover **every** feedback item from the review comment, formatted as:

   ```
   ## Review Feedback Response

   **Fixed**
   - [item] — [brief explanation of what was changed]

   **Deferred**
   - [item] — [reason: too large a refactor / architectural decision / out of scope]

   **Skipped**
   - [item] — [reason: already correct / informational only / intentional design]
   ```

   Nothing is silently omitted. Every item appears in one of the three sections.

## Notes
- Always read files before editing — never apply a fix based on the review comment alone.
- Do not skip pre-commit hooks or force push.
- If the review comment URL is a line-level comment, use `gh api repos/{owner}/{repo}/pulls/comments/{id}` to fetch it.
