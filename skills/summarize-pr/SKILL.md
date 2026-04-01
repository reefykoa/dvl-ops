---
name: summarize-pr
description: Generate dual summaries of a GitHub PR — one non-technical TLDR for stakeholders and one engineering summary — each covering Current Problems, Root Cause, and Proposed Solution. Use this skill when the user wants to summarize PR changes, create a PR write-up, explain what a PR does, or says "summarize this PR", "write up the changes", "give me a TLDR of the PR", "explain the PR for non-technical people", or "write a summary of the changes".
user_invocable: true
---

Generate two structured summaries of a GitHub PR: a non-technical TLDR and an engineering summary. Each covers the same three sections — Current Problems, Root Cause, Proposed Solution — at different levels of detail.

## Step 1 — Collect inputs

Use `AskUserQuestion` to ask: "What is the GitHub PR URL?"

Use `AskUserQuestion` to ask: "Should I post these summaries as a comment on the PR?" with options: Yes / No (display in terminal only).

## Step 2 — Fetch the PR

Parse `owner`, `repo`, and PR number from the URL.

Run:
```
gh pr view <number> --repo <owner>/<repo> --json title,body,files,commits
gh pr diff <number> --repo <owner>/<repo>
```

Read the PR title, description, and the diff. For each changed file, read its current contents focusing on sections most relevant to understanding what problem is being solved and how.

## Step 3 — Generate summaries

Produce two summaries. Both use the same three-section structure:

**Section 1 — Current Problems**
What is broken, painful, or missing before this PR? Describe the user-facing or developer-facing symptom.

**Section 2 — Root Cause**
Why does the problem exist? What is the underlying technical or product reason?

**Section 3 — Proposed Solution**
What does this PR do to fix it? How does the change work?

---

### Non-Technical Summary (TLDR)

- Plain language — no code references, no jargon
- Each section ≤ 50 words
- Written for a product manager, stakeholder, or customer success rep who needs to understand the impact without implementation details

### Engineering Summary

- Technical detail — include relevant file names, function names, API changes, or architectural decisions
- Each section ≤ 100 words
- Written for an engineer who needs to understand the approach well enough to review or build on it

## Step 4 — Display in terminal

Print both summaries clearly labeled:

```
## Non-Technical Summary (TLDR)

### Current Problems
...

### Root Cause
...

### Proposed Solution
...

---

## Engineering Summary

### Current Problems
...

### Root Cause
...

### Proposed Solution
...
```

## Step 5 — Post to PR (if requested)

If the user chose "Yes" in Step 1:
1. Write the formatted output to `/tmp/pr-summary-<PR_NUMBER>.md`
2. Post as a PR comment:
   ```
   gh pr comment <number> --repo <owner>/<repo> --body-file /tmp/pr-summary-<PR_NUMBER>.md
   ```
3. Output the URL of the posted comment so the user can verify it.

## Rules

- Base all content strictly on what is in the PR diff and description — do not invent problems or solutions not evidenced by the code.
- If the PR description already explains the problem well, use it as a primary source but synthesize — do not copy-paste it verbatim.
- If the root cause cannot be determined from the PR alone (e.g. it references an external bug report), note this and describe the symptoms instead.
- Keep non-technical language genuinely accessible — avoid technical terms even if commonly used by engineers.
