---
name: reply-to-conversations
description: Given a list of GitHub discussion/conversation URLs, post an individual in-thread reply to each one explaining what was changed, addressed, ignored, or deferred — based on the most recent commit or specified changes. Use this skill when the user says "reply to these unresolved conversations with what was changed", "respond to these discussion threads", or provides a list of GitHub discussion URLs and wants a reply posted to each.
user_invocable: true
---

Post a targeted in-thread reply to each provided GitHub conversation URL, summarizing how each concern was handled.

## Steps

1. **Gather context.** If not provided in `$ARGUMENTS`, prompt the user for:
   - The list of GitHub discussion/conversation URLs to reply to.
   - Whether to base replies on the last commit (default) or on a specific change description the user provides.

2. **Fetch the diff or change context.**
   - If basing on last commit: run `git diff HEAD~1 HEAD` to get the diff.
   - If the user provides a description, use that directly.

3. **For each conversation URL:**
   a. Fetch the comment body:
      ```
      gh api repos/{owner}/{repo}/pulls/comments/{comment_id}
      ```
      or for issue comments:
      ```
      gh api repos/{owner}/{repo}/issues/comments/{comment_id}
      ```
      Parse the URL to determine whether it's a pull request line comment or a general issue/PR comment.

   b. Identify the specific concern raised in that conversation.

   c. Determine the status based on the diff/change context:
      - **Changed**: the concern was directly addressed in the recent changes.
      - **Addressed**: the concern was handled in spirit (partial fix, added comment, refactored intent).
      - **Deferred**: valid point, explicitly left for a follow-up.
      - **Ignored/Skipped**: not applicable, already correct, or intentionally out of scope.

   d. Post an in-thread reply via:
      ```
      gh api repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies \
        --method POST \
        --field body="..."
      ```
      For issue comments, use:
      ```
      gh pr comment {pr_number} --body "..."
      ```
      Keep each reply concise (2–4 sentences): state the status, briefly explain what changed or why it was skipped.

4. **Confirm** the number of replies posted and list any conversation URLs that could not be replied to (with reason).

## Notes
- Post individual replies to each thread — do not consolidate into a single PR comment.
- Never fabricate changes. If the diff does not address a concern, mark it Deferred or Ignored with an honest explanation.
- If a URL cannot be parsed or the API returns an error, report it and continue with the remaining URLs.
- Do not commit or push any code changes as part of this skill.
