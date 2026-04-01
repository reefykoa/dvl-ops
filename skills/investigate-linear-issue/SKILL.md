---
name: investigate-linear-issue
description: "Investigates a Linear issue end-to-end — reading the issue, all comments, linked Slack threads, and external references — then posts a structured 8-section analysis comment (summary, steps to reproduce, customer impact, root cause, first reported, occurrence count, first affected release, proposed solution) directly on the ticket. USE THIS SKILL IMMEDIATELY when the user shares a linear.app URL or a Linear issue ID (like FLEXOPS-103, MOB-456, COREOPX-132) alongside any of these intents: investigate, analyze, triage, dig into, write up, post findings, leave a comment, pull together the analysis, write an incident report, root cause analysis, or 'what do we know about this'. Concrete trigger patterns: 'investigate this for me <url>', 'do a root cause analysis on FLEXOPS-177 and post it', 'triage FLEXOPS-98 and leave a comment', 'dig into MOB-843 and leave a comment with everything we know', 'just got pulled into a bug review <url> can you post the analysis', 'write up an incident report for FLEXOPS-103 and post it as a comment', 'what do we know about FLEXOPS-97 post a summary comment'. Do NOT use this skill when the user only wants to read/discuss an issue in chat without posting back, wants to create a new ticket, update issue fields, search for issues, or implement a fix."
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

## Step 4: Synthesize the findings

Work through each of these eight questions carefully. For any question where the evidence is ambiguous or missing, say so directly — do not invent data.

1. **Brief summary** — What is the issue and what is its user-facing impact? (2–3 sentences max)

2. **Steps to reproduce** — Concrete, ordered steps a developer or QA engineer could follow to see the problem themselves. Infer from available evidence if not explicitly stated; label inferred steps as such.

3. **Customer impact** — How many customers or users are affected? Are specific customers named? What is the severity of impact for those affected? Cite your source.

4. **Root cause** — The specific technical reason this is happening. If confirmed, state it. If a hypothesis, label it as such and explain the reasoning. If unknown, say what additional investigation is needed. When the root cause is not clearly stated in comments or Slack, **search the codebase** — look at the relevant files, functions, and manifest entries mentioned in the issue. Codebase investigation often reveals the precise mechanism (e.g., a missing node type in a parser's fallback path, a wrong manifest flag) that external reports can only describe in terms of symptoms.

5. **First reported** — The earliest date and time this issue was mentioned in any source (Linear description, comment, Slack, etc.). Include the source.

6. **Occurrence count** — How many times has this been observed, reported, or logged? Aggregate across all sources (Slack mentions, customer tickets, crash reports, etc.). If you have a range, give it.

7. **First affected release** — What app version, build number, or release name did this first appear in? If not directly stated, note that and include any version information found.

8. **Proposed solution** — Concrete, actionable steps to fix this. Include both the immediate fix and any follow-up needed (e.g., data backfill, monitoring). If the root cause is still uncertain, describe investigation steps first.

## Step 5: Post the comment

Use the Linear MCP `save_comment` tool to post the analysis on the issue.

Use this exact format for the comment body:

```
## Issue Analysis

**Summary**
<2–3 sentence description of the issue and its impact>

**Steps to Reproduce**
1. <step>
2. <step>
3. ...

**Customer Impact**
<count or estimate of affected customers, with source — e.g., "3 named customers per Slack thread (2026-03-15)">

**Root Cause**
<confirmed root cause, or clearly labeled hypothesis with reasoning>

**First Reported**
<absolute date + source — e.g., "2026-03-12 via Slack #mobile-bugs">

**Occurrence Count**
<number or range with sources — e.g., "~8 reports: 3 Slack mentions, 5 customer tickets">

**First Affected Release**
<version or "Unknown — no version data found; needs investigation">

**Proposed Solution**
<numbered list of concrete steps to fix this, including follow-up work>

---
*Analysis generated by Claude — verify before acting*
```

## Tips for good analysis

- **Dates**: When sources give relative dates ("last Tuesday", "a few days ago"), convert to absolute dates. Today is {{CURRENT_DATE}}.
- **Confidence**: Label anything inferred or uncertain. Readers need to know what is confirmed vs. estimated.
- **Brevity**: Keep each section scannable. Engineers will act on this — they don't need a wall of text.
- **Signal over noise**: In long Slack threads, focus on the first message, engineer responses, and the most recent status update. Skip emoji reactions and off-topic tangents.
- **Don't skip sections**: If you truly cannot find data for a section, write "Unknown — [what would help find it]" rather than omitting it.
