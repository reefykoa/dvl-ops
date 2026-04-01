---
name: investigate-linear-issue
description: "Investigates a Linear issue end-to-end — reading the issue, all comments, linked Slack threads, and external references — then posts a structured 8-section analysis comment (summary, steps to reproduce, customer impact, root cause, first reported, occurrence count, first affected release, proposed solution) directly on the ticket. USE THIS SKILL IMMEDIATELY when the user shares a linear.app URL or a Linear issue ID (like FLEXOPS-103, MOB-456, COREOPX-132) alongside any of these intents: investigate, analyze, triage, dig into, write up, post findings, leave a comment, pull together the analysis, write an incident report, root cause analysis, or 'what do we know about this'. Concrete trigger patterns: 'investigate this for me <url>', 'do a root cause analysis on FLEXOPS-177 and post it', 'triage FLEXOPS-98 and leave a comment', 'dig into MOB-843 and leave a comment with everything we know', 'just got pulled into a bug review <url> can you post the analysis', 'write up an incident report for FLEXOPS-103 and post it as a comment', 'what do we know about FLEXOPS-97 post a summary comment'. Do NOT use this skill when the user only wants to read/discuss an issue in chat without posting back, wants to create a new ticket, update issue fields, search for issues, or implement a fix."
user_invocable: true
---

## What you are doing

You are a senior engineer performing a thorough investigation of a Linear issue. Your goal is to gather all available evidence, synthesize it clearly, and post a structured comment on the issue that gives the team everything they need to understand and fix the problem quickly.

## Step 1: Extract the issue ID

Parse the Linear issue ID from the URL or message. Linear URLs follow this pattern:
`https://linear.app/<team>/issue/<ISSUE-ID>/<title-slug>`

The issue ID looks like `FLEXOPS-103` or `MOB-456`. Extract it.

## Step 2: Fetch the issue and all comments

Use the Linear MCP tools to read:
- The issue details (title, description, state, priority, labels, assignee, createdAt, cycle/project)
- All comments on the issue

As you read, look for and note:
- Slack thread URLs (slack.com/archives/...)
- GitHub PR or commit links
- Datadog, Sentry, or other observability links
- Version numbers, release names, or build numbers mentioned
- Customer names, counts, or account IDs
- Dates of first occurrence or customer reports
- Any mention of a workaround or proposed fix
- **Attachment filenames**: Screen recording and screenshot filenames often embed the recording date (e.g., `Screen_Recording_20251109_101232_...` → recorded 2025-11-09). This can be the earliest evidence of an issue, predating any Slack or comment timestamps.

## Step 3: Follow external links

**Slack threads**: For any Slack URL found, use the Slack MCP tools to read the thread. Focus on:
- The original message (when was it posted, by whom)
- Engineer responses discussing root cause or impact
- Mentions of affected customers or release versions
- Any resolution or workaround discussed
- Go one level deep — read the linked thread, but do not recursively follow sub-links within it

**Other external links**: Use WebFetch or available MCP tools (GitHub, Datadog, etc.) as appropriate to gather additional context. Use judgment — fetch what will materially help the analysis, skip links that are likely noise (e.g., generic documentation URLs).

## Step 4: Synthesize and post

Read `.claude/skills/_shared/issue-analysis-format.md` for the synthesis questions, output format, and analysis rules.

Work through all eight synthesis questions using the evidence gathered above, then use the Linear MCP `save_comment` tool to post the result on the issue. Use `## Issue Analysis` as the comment heading.
