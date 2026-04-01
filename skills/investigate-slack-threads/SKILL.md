---
name: investigate-slack-threads
description: Read one or more Slack threads, synthesize an 8-section issue analysis (summary, steps to reproduce, customer impact, root cause, first reported, occurrence count, first affected release, proposed solution), and optionally post it to Linear or GitHub. Use this skill when the user shares Slack thread URLs and wants to investigate or triage an issue, or says "look into this Slack thread", "analyze these Slack messages", "investigate this from Slack", "triage this Slack report", or "write up what's in these threads". Different from investigate-linear-issue which starts from a Linear ticket.
user_invocable: true
---

Read Slack threads end-to-end, synthesize a structured 8-section analysis, and optionally post it to Linear or GitHub.

## Step 1 — Collect inputs

Use `AskUserQuestion` to ask: "Paste the Slack thread URL(s) to investigate (one per line)."

Use `AskUserQuestion` to ask: "Which GitHub repo(s) should I search for root cause? (format: `owner/repo`, one per line — leave blank to skip code search)"

Use `AskUserQuestion` to ask: "Where should I post the analysis?" with options:
- Post to a Linear issue (provide URL)
- Post to a GitHub PR (provide URL)
- Display in terminal only

If the user selects Linear or GitHub, follow up with: "Paste the Linear issue URL or GitHub PR URL."

## Step 2 — Read the Slack threads

For each Slack URL provided, use the Slack MCP tools to read the thread.

While reading, extract and note:
- **Timestamps** — when each message was sent (convert to absolute dates; today is {{CURRENT_DATE}})
- **Authors** — who reported the issue, who responded
- **Customer names or account IDs** — any named customers or counts of affected users
- **Error messages or stack traces** — exact text of errors
- **Version or release numbers** — app version, build number, or release name mentioned
- **Linked URLs** — GitHub PRs, Datadog/Sentry dashboards, Linear issues, or other external references
- **Any proposed workarounds or resolutions** discussed in the thread

Go one level deep — read the linked threads, but do not recursively follow every sub-link found within them. Use judgment: fetch external links that will materially help the analysis; skip generic documentation links.

## Step 3 — Follow external links

For any linked URLs found in the threads:
- **GitHub PR or commit**: use `gh pr view` or `gh api` to read the description and diff
- **Linear issue**: use `mcp__claude_ai_Linear__get_issue` and `mcp__claude_ai_Linear__list_comments`
- **Datadog**: use the Datadog MCP tools to fetch relevant logs or metrics
- **Other URLs**: use `WebFetch` if the URL is likely to have useful context

## Step 4 — Search repos (if provided)

For each repo provided in Step 1, search for code paths referenced in the threads — error message strings, function names, file names, or feature flags mentioned. Use `mcp__github__search_code` or `gh api` to look up the relevant code.

Focus on identifying the specific mechanism causing the reported behavior.

## Step 5 — Synthesize and post

Read `.claude/skills/_shared/issue-analysis-format.md` for the synthesis questions, output format, and analysis rules.

Work through all eight synthesis questions using the evidence gathered above. Use `## Issue Analysis (from Slack)` as the heading.

Then post according to the destination chosen in Step 1:

**Display in terminal only:** print the formatted analysis.

**Post to Linear:**
1. Extract the issue ID from the URL (e.g. `FLEXOPS-103`)
2. Use `mcp__claude_ai_Linear__save_comment` with `issueId` set to the issue ID and `body` set to the formatted analysis
3. Confirm to the user that the comment was posted and provide the issue URL

**Post to GitHub PR:**
1. Parse `owner`, `repo`, and PR number from the URL
2. Write the analysis to `/tmp/slack-investigation-<timestamp>.md`
3. Run: `gh pr comment <number> --repo <owner>/<repo> --body-file /tmp/slack-investigation-<timestamp>.md`
4. Output the URL of the posted comment

## Additional rule (Slack-specific)

If multiple Slack threads describe different issues, note this clearly at the top of the analysis and handle each separately or ask the user which to focus on.
