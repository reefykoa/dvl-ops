---
name: sync-project-docs
description: Read the Linear project overview, all Done/closed issues, all closed PRs, and current repo files, then update project plan markdown docs in a specified directory to accurately reflect what has been built. Use this skill when the user says "update the project plans", "sync the project docs", "update the markdown files in project-plans/", or wants the narrative documentation to reflect the current state of the project.
user_invocable: true
---

## What you are doing

You are synchronizing the project's narrative documentation with its actual current state — what has been built, what was changed from the original plan, and what remains outstanding. The goal is documentation that a new team member could read to accurately understand where the project stands.

## Step 1: Gather context

If not provided in `$ARGUMENTS`, prompt the user for:
- The Linear project URL or project name.
- The local directory containing the project plan markdown files (e.g., `~/project-plans/surf_window/`).
- The GitHub repo URL (if not inferable from `git remote`).

## Step 2: Collect source data in parallel

Gather all of the following:

**Linear:**
- Project overview (title, description, goals, milestones) via Linear MCP.
- All issues with status Done — title, description, assignee, milestone, completion date.
- All issues with status In Progress or Backlog — title, description, status.

**GitHub:**
- All closed PRs: title, number, merged date, linked branch, PR description.
  ```
  gh pr list --state closed --limit 100 --json number,title,mergedAt,body,headRefName
  ```
- Current repo file tree (top-level and key subdirectories):
  ```
  git ls-files | head -200
  ```

**Local files:**
- Read all existing markdown files in the target docs directory.

## Step 3: Compare and identify gaps

For each existing markdown file:
- Identify sections that describe work that has since been completed (move to "done" or remove if purely planning content).
- Identify sections that are outdated (reference architecture, file paths, or APIs that no longer exist).
- Identify missing content: completed work not yet documented, new modules/patterns introduced by merged PRs.

## Step 4: Update the markdown files

Apply updates in-place to the existing markdown files:
- Mark completed items as done (convert `[ ]` to `[x]`, move items to a "Completed" section, or add a completion note with date).
- Remove or archive planning content that is no longer accurate.
- Add new sections for significant work that was delivered but not yet documented.
- Update file paths, module names, and architecture descriptions to match the current codebase.
- If a file is entirely superseded, note what replaced it and whether it can be removed (ask the user before deleting).

Prefer updating existing files over creating new ones. Only create a new file if there is a substantial new topic with no logical home in the existing structure.

## Step 5: Confirm with the user

After all updates, provide a summary of:
- Files modified and what changed in each.
- Files that could be deleted (ask for confirmation before removing).
- Any new files created.
- Items that remain outstanding (not yet implemented, still in backlog).

## Notes
- Never fabricate implementation details. If something is unclear from the PR descriptions and Linear issues, note it as "unverified" rather than guessing.
- Preserve the author's voice and formatting style in each file — do not rewrite prose unnecessarily.
- Convert relative dates (e.g., "last week") to absolute dates when encountered.
- If the Linear project or GitHub repo is inaccessible, work with whatever data is available and note the gap.
