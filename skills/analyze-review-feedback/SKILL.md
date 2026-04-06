---
name: analyze-review-feedback
description: Read PR review comments (CodeRabbit or human reviewer) and give an opinion on which items should be fixed, addressed, skipped, or deferred — WITHOUT implementing any changes. Use this skill when the user says "what are your thoughts on these comments", "analyze this feedback", "should I address this review", or wants a pre-flight opinion before committing to action.
user_invocable: true
---

Read the review comments and give a clear, prioritized opinion on how to handle each item — without making any code changes.

## Steps

1. **Gather context.** If not provided in `$ARGUMENTS`, prompt the user for:
   - The PR URL or PR number.
   - The review comment URL(s) or comment ID(s) to analyze.

2. **Fetch each review comment.** For each URL provided, run:
   ```
   gh api <review-comment-url-path>
   ```
   Parse the full comment body. List every distinct feedback item.

3. **For each feedback item, assess:**
   - **Validity**: Is the concern technically correct? Is it based on accurate assumptions about the code?
   - **Priority**: Classify as High, Medium, or Low using these criteria:
     - **High**: correctness bugs, security issues, broken contracts, missing tests for critical paths — must fix.
     - **Medium**: naming, code clarity, minor refactors, style inconsistencies that affect readability — worth fixing but judgment call.
     - **Low**: nitpicks, stylistic preferences, optional suggestions — can skip or defer without impact.
   - **Recommendation**: one of Fix / Address (partial fix or explanation) / Defer (valid but out of scope) / Skip (invalid, incorrect, or not applicable).

4. **Output a prioritized analysis.** Format the response as:

   ```
   ## Review Feedback Analysis

   ### [Item title or short quote]
   - **Priority**: High / Medium / Low
   - **Validity**: [Is the concern correct? Any misunderstanding of the code?]
   - **Recommendation**: Fix / Address / Defer / Skip
   - **Rationale**: [Why — 1–2 sentences]

   ### [Next item...]
   ...

   ## Summary
   - Fix immediately: [count] items
   - Worth addressing: [count] items
   - Defer or skip: [count] items
   ```

## Notes
- This skill is analysis only — do not make code changes, commit, or push anything.
- If the reviewer's comment reflects a misunderstanding of the code, note that explicitly and recommend Skip with a suggested reply.
- If a comment URL is a line-level comment, use `gh api repos/{owner}/{repo}/pulls/comments/{id}` to fetch it.
- If multiple review comment URLs are provided, analyze them all in a single pass.
