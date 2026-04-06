---
name: investigate-slack-threads
description: Accept a list of raw Slack thread URLs (no Linear issue required), read the threads, determine whether the issues described are related or distinct, and produce the standard 8-section analysis. Use this skill when the user says "investigate these Slack threads", "read these Slack threads and find the root cause", "analyze these Slack conversations", or provides Slack URLs and wants a structured root cause investigation.
user_invocable: true
---

## What you are doing

You are a senior engineer investigating one or more Slack threads to determine root cause, customer impact, and a proposed solution. Your goal is to read all provided threads, determine if they represent the same issue or distinct issues, synthesize the evidence, and produce a clear structured analysis.

## Step 1: Gather the thread URLs

Parse Slack thread URLs from `$ARGUMENTS`. If none are provided, prompt the user for:
- The Slack thread URL(s) to investigate.
- Any GitHub repos or other systems to search for root cause (optional).

## Step 2: Read each Slack thread

Use available Slack MCP tools to read each thread. For each thread, collect:
- Original message: timestamp, author, description of the problem.
- Replies: engineer commentary, reproduction details, affected users/accounts, version mentions, workarounds, resolutions.
- Any linked external resources (GitHub PRs, commits, Datadog/Sentry links, Linear issues).

Go one level deep — read each linked thread, but do not recursively follow sub-links within replies.

## Step 3: Determine relationship between threads

If multiple thread URLs were provided, assess whether the issues are:
- **The same issue** (same root cause, same symptoms): consolidate into one analysis.
- **Related issues** (overlapping root cause or component, different symptoms): note the relationship in the analysis.
- **Distinct issues** (different root causes, different components): produce a separate analysis for each.

State your determination at the top of the output.

## Step 4: Follow external links

For any GitHub PR, commit, or issue links found, use the GitHub MCP or WebFetch to gather additional root cause context. For observability links (Datadog, Sentry), use WebFetch if available.

If repos to search were specified by the user, search them for the relevant code path or commit.

## Step 5: Synthesize and output

Read `.claude/skills/_shared/issue-analysis-format.md` for the synthesis questions, output format, and analysis rules.

Work through all eight synthesis questions using the evidence gathered, then produce the structured analysis in the console. Use `## Slack Thread Investigation` as the heading.

If the threads describe distinct issues, produce one analysis block per issue, each with its own `## Issue N: [short title]` sub-heading.

## Notes
- Label inferences clearly — distinguish between what was explicitly stated and what you are inferring from evidence.
- Convert all relative timestamps to absolute dates.
- If a Slack thread is inaccessible or returns an error, note it and work with whatever evidence is available.
- This skill outputs to the console only — it does not post to Linear or GitHub unless the user explicitly asks to follow up with `post-analysis-to-linear` or `post-analysis-to-github`.
