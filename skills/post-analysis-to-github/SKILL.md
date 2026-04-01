---
name: post-analysis-to-github
description: Post the most recent analysis, implementation plan, or structured output from this conversation as a GitHub PR comment. Use this skill whenever the user wants to share findings or analysis on a PR, post conversation results to GitHub, or says "post this to the PR", "add this as a PR comment", or "share the analysis on GitHub".
user_invocable: true
---

Post the most recent analysis from this conversation as a GitHub PR comment.

## Steps

1. **Parse the PR number** from `$ARGUMENTS` (e.g. `42`). If `$ARGUMENTS` is empty, use `AskUserQuestion` to ask the user for the PR number.

2. **Derive the temp file path**: `/tmp/pr-<PR_NUMBER>-implementation-details-analysis.md`

3. **Write the analysis to the temp file** (overwrite if it exists). The content is the most recent analysis, implementation plan, or structured output generated in this conversation. Apply these formatting rules:
   - Outstanding / TODO items → `- [ ] <item>`
   - Completed / done items → `- [x] <item>`
   - Preserve all headings, paragraphs, and code blocks as-is

4. **Post the comment** by running:
   ```bash
   gh pr comment <PR_NUMBER> --body-file /tmp/pr-<PR_NUMBER>-implementation-details-analysis.md
   ```

5. **Confirm** by reporting:
   - The temp file path that was written
   - That the comment was successfully posted to the GitHub PR
