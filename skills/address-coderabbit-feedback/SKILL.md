---
name: address-coderabbit-feedback
description: Fix unresolved CodeRabbit review comments on a PR and reply inline to each thread. Use this skill when the user says "address coderabbit feedback", "fix the coderabbit comments", or wants to resolve AI review threads on a PR.
user_invocable: true
---

Fix unresolved CodeRabbit review comments and reply inline to each thread.

## Steps

1. **Resolve the PR number.** If `$ARGUMENTS` contains a number, use it. Otherwise, detect the current branch with `git branch --show-current` and run `gh pr view --json number --jq .number`.

2. **Fetch unresolved CodeRabbit threads.** Run:
   ```
   gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments --paginate
   ```
   Filter for comments where `user.login == "coderabbitai[bot]"` and the thread is not resolved. Group comments by thread (by `in_reply_to_id` — top-level comments have no `in_reply_to_id`).

3. **Infer owner/repo.** Run `git remote get-url origin` and parse the owner and repo from the URL.

4. **Triage each thread.**
   - **Actionable** — CodeRabbit identified a concrete problem (bug, missing null check, incorrect type, unhandled error, etc.). Apply a fix.
   - **Informational** — CodeRabbit made an observation or suggestion without a concrete problem. Acknowledge without code changes.
   - Skip threads that are already resolved or are pure praise.

5. **Apply fixes for actionable threads.**
   - Read the relevant file and line before making any change.
   - Apply a targeted, minimal fix. Do not refactor surrounding code.
   - Do not apply a fix that would break existing tests or cause a regression.

6. **Commit and push.** Once all fixes are applied:
   - Stage modified files explicitly.
   - Write a commit message: "address coderabbit feedback on PR #<N>".
   - Push the branch.

7. **Reply inline to each thread.** For every thread processed (actionable or informational), post a reply:
   ```
   gh api repos/{owner}/{repo}/pulls/comments/<comment_id>/replies \
     -f body="<reply>"
   ```
   - For fixed items: explain what was changed.
   - For informational items: acknowledge and explain why no change was made.

## Notes
- Informational comments should be acknowledged — never silently ignored.
- Do not resolve threads programmatically; let CodeRabbit or the PR author mark them resolved after reviewing your reply.
- If a fix is too large or architectural, defer it with a comment explaining the scope and suggesting a follow-up issue.
