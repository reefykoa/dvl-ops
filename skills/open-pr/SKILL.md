---
name: open-pr
description: Stage, commit, push, and create a GitHub pull request. Use this skill whenever the user says "open a PR", "create a pull request", "make a PR", or wants to submit their current work for review.
user_invocable: true
---

Stage, commit, push, and create a GitHub pull request.

## Steps

1. **Check for changes.** Run `git status` and `git diff`. If there are no staged or unstaged changes and no commits ahead of the remote, stop and tell the user there is nothing to include in a PR.

2. **Detect the default branch.** Run `git remote show origin | grep 'HEAD branch'` to find the base branch (usually `main` or `master`).

3. **Stage and commit if needed.** If there are unstaged or uncommitted changes:
   - Run `git diff` and `git diff --cached` to review what will be committed.
   - Stage specific files with `git add <file>` — avoid `git add -A` to prevent accidentally committing secrets (`.env`, credentials).
   - Check recent commit style with `git log --oneline -5`.
   - Write a concise commit message that explains *why* the change exists, not just what changed.
   - Commit with `git commit -m "..."`.

4. **Push the branch.** Run `git push -u origin <current-branch>`. If the push fails due to a network error, retry up to 4 times with exponential backoff (2s, 4s, 8s, 16s). Do not force push.

5. **Create the PR.** Run:
   ```
   gh pr create --title "<title>" --body "<body>"
   ```
   - Keep the title under 70 characters.
   - Body should include a summary (1–3 bullet points) and a test plan checklist.
   - Base the PR against the default branch detected in step 2.

6. **Trigger code review.** After the PR URL is obtained:
   - Extract the Linear issue ID from the branch name: run `git rev-parse --abbrev-ref HEAD`, take the path segment after the first `/`, match the leading `[a-z]+-[0-9]+` token, and uppercase it (e.g. `reefykoa/sw-110-foo` → `SW-110`).
   - If a Linear issue ID is found, post a comment to it using the `mcp__claude_ai_Linear__save_comment` tool with `body: "@claude review"`.
   - If no issue ID can be parsed from the branch name, skip this step silently.

7. **Report back.** Share the PR URL with the user. Note whether a `@claude review` comment was posted to Linear.

## Notes
- Never commit files that likely contain secrets (`.env`, `credentials.json`, `*.pem`, etc.). Warn the user if they specifically request committing those files.
- Do not amend published commits. Create a new commit instead.
- Do not skip pre-commit hooks (`--no-verify`). If a hook fails, fix the underlying issue.
