---
name: push-up-changes
description: Stage relevant files, commit with a descriptive message, and push the current branch. Use this skill whenever the user says "push up my changes", "commit and push", "save my work", or wants to checkpoint progress without opening a PR.
user_invocable: true
---

Stage relevant files, commit, and push the current branch.

## Steps

1. **Review current state.** Run these in parallel:
   - `git status` — see all modified and untracked files.
   - `git diff` — see unstaged changes.
   - `git diff --cached` — see already-staged changes.
   - `git log --oneline -5` — understand recent commit message style.

2. **Stage specific files.** Prefer staging files by name (`git add <file>`) rather than `git add -A` or `git add .` to avoid accidentally including secrets (`.env`, credentials, large binaries). If the user hasn't specified which files, stage all modified tracked files and ask about untracked ones.

3. **Write a commit message.** Follow the existing commit style observed in step 1. Write a concise message (1–2 sentences) that explains *why* the change exists, not just what changed. Pass via heredoc:
   ```
   git commit -m "$(cat <<'EOF'
   <message>
   EOF
   )"
   ```

4. **Push.** Run `git push -u origin <current-branch>`. If the push fails due to a network error, retry up to 4 times with exponential backoff (2s, 4s, 8s, 16s). Do not force push unless the user explicitly requests it.

5. **Confirm.** Report the commit hash and the remote branch URL.

## Notes
- Do not skip pre-commit hooks (`--no-verify`). If a hook fails, diagnose and fix the root cause.
- Do not amend published commits. Always create a new commit.
- If there are no changes to commit, tell the user and stop — do not create an empty commit.
