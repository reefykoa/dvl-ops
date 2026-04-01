---
name: post-review-followup
description: Read the last commit diff and post a PR comment summarizing how each piece of feedback from a specific review comment was handled. Use this skill when the user says "post a review followup", "summarize how I addressed feedback", or wants to document their response to a reviewer.
user_invocable: true
---

Read the last commit diff and post a PR comment classifying how each item of reviewer feedback was handled.

## Steps

1. **Gather context.** If not provided in `$ARGUMENTS`, prompt the user for:
   - The PR URL or PR number.
   - The review comment URL to follow up on.

2. **Fetch the review comment.** Run:
   ```
   gh api <review-comment-url-path>
   ```
   List every distinct feedback item from the comment body.

3. **Fetch the last commit diff.** Run:
   ```
   git diff HEAD~1 HEAD
   ```
   This is the diff that represents the response to the feedback.

4. **Classify each feedback item** by comparing it against the diff:
   - **Fixed** — the diff contains a change that directly addresses the item.
   - **Addressed** — the diff contains a related change that partially or indirectly resolves the concern.
   - **Deferred** — no change in the diff; intentionally left for a follow-up.
   - **Skipped** — no change; the item was informational, already correct, or intentionally not acted on.
   - **Ignored** — no change and no clear rationale (flag this to the user before posting).

5. **Post the followup comment.** Run:
   ```
   gh pr comment <PR_NUMBER> --body "..."
   ```
   Format:
   ```
   ## Review Followup

   | Feedback | Status | Notes |
   |----------|--------|-------|
   | [item]   | Fixed  | [what changed] |
   | [item]   | Deferred | [reason] |
   ...
   ```

   Every feedback item from the review comment must appear in the table. Nothing is silently omitted.

## Notes
- This skill makes **no code changes** — it is read-only except for the comment it posts.
- If the last commit doesn't correspond to the review feedback (e.g., it's an unrelated change), flag this to the user before posting.
- Use `gh api repos/{owner}/{repo}/pulls/comments/{id}` if the review comment URL is a line-level comment.
