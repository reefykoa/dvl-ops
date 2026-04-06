---
name: summarize-document
description: Generate dual summaries of any document or pasted text — a non-technical TLDR (≤50 words per section) and an engineering summary (≤100 words per section), both covering Current Problems, Root Cause, and Proposed Solution. Use this skill when the user says "summarize this document", "give me a dual summary of this text", "TLDR this for non-technical people", "summarize this for engineers and stakeholders", or provides a document path or pastes text and asks for a summary.
user_invocable: true
---

Generate two summaries of the provided document or text — one for non-technical stakeholders, one for engineers.

## Steps

1. **Gather content.** From `$ARGUMENTS` or the conversation:
   - If a file path is provided, read the file using the Read tool.
   - If a URL is provided, fetch the content using WebFetch.
   - If text is pasted directly, use that.
   - If nothing is provided, prompt the user for the document path, URL, or text to summarize.

2. **Identify the three key dimensions** of the content:
   - **Current Problems**: What issue, gap, or situation is described?
   - **Root Cause**: What underlying factor explains the problem or situation?
   - **Proposed Solution**: What action, change, or recommendation is being made?

   If the document does not map cleanly to these three sections (e.g., it is purely informational with no problem/solution structure), adapt the section titles to fit the content — use what is most useful for the reader.

3. **Write the non-technical summary.**
   - Plain language — no code, no jargon, no acronyms without explanation.
   - Written for product managers, stakeholders, or customers.
   - Each section: ≤50 words.

4. **Write the engineering summary.**
   - Technical detail — file names, function names, API changes, system components are appropriate.
   - Written for engineers who need to act on or understand the content.
   - Each section: ≤100 words.

5. **Output both summaries** in the following format:

   ```
   ## Non-Technical Summary

   **Current Problems**
   [≤50 words]

   **Root Cause**
   [≤50 words]

   **Proposed Solution**
   [≤50 words]

   ---

   ## Engineering Summary

   **Current Problems**
   [≤100 words]

   **Root Cause**
   [≤100 words]

   **Proposed Solution**
   [≤100 words]
   ```

6. **Optionally post the output.** If the user asks to post the summaries:
   - To a GitHub PR: write to `/tmp/summary-<identifier>.md` and run `gh pr comment <PR_NUMBER> --body-file <file>`.
   - To a Linear issue: use the Linear MCP `save_comment` tool.
   - Otherwise, output to the console only.

## Notes
- Base both summaries strictly on the provided content — do not invent problems or solutions.
- Keep non-technical language genuinely accessible — avoid euphemisms that obscure meaning.
- If the document is very long (>5000 words), read it in sections and synthesize across all sections before writing.
- This skill is not PR-specific — it works on any text: incident reports, design docs, Linear issues, API specs, changelogs, etc.
