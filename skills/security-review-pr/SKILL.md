---
name: security-review-pr
description: Audit a GitHub PR for security vulnerabilities — OWASP Top 10, hardcoded secrets, broken authentication, injection risks, and GitHub Actions secrets/permissions misuse. Use this skill when the user says "are there any security concerns in this PR", "security review this PR", "check for vulnerabilities", "do a security audit", or "are there any OWASP issues".
user_invocable: true
---

Perform a structured security audit of a PR's changes and produce a prioritized findings report.

## Steps

1. **Gather context.** If not provided in `$ARGUMENTS`, prompt the user for:
   - The PR URL or PR number.

2. **Fetch the PR diff and metadata.**
   ```
   gh pr view <PR_NUMBER> --json title,body,headRefName,baseRefName,files
   gh pr diff <PR_NUMBER>
   ```

3. **Read changed files.** For each changed file in the diff, read the full current file content using the Read tool. Focus on files that introduce new logic, handle input, touch authentication/authorization, or modify CI/CD configuration.

4. **Audit for each security category:**

   **A. Injection risks** (OWASP A03)
   - SQL injection: raw query concatenation, unparameterized queries.
   - Command injection: unsanitized user input passed to shell commands, `exec`, `eval`, or subprocess calls.
   - XSS: unsanitized user content rendered as HTML, missing output encoding.

   **B. Broken authentication / authorization** (OWASP A01, A07)
   - Missing auth checks on new routes or endpoints.
   - Insecure direct object references (IDOR): accessing resources without ownership validation.
   - Weak or missing session handling.

   **C. Hardcoded secrets** (OWASP A02)
   - API keys, tokens, passwords, or private keys committed in source.
   - Secrets in config files, test fixtures, or environment defaults.

   **D. Sensitive data exposure** (OWASP A02)
   - PII or credentials logged to console/files.
   - Sensitive data in error messages returned to clients.
   - Unencrypted storage of sensitive values.

   **E. Security misconfiguration** (OWASP A05)
   - Overly permissive CORS settings.
   - Debug modes or verbose error output enabled in production paths.
   - Insecure default configurations introduced.

   **F. GitHub Actions security** (if `.github/workflows/` files are changed)
   - Secrets referenced correctly via `${{ secrets.X }}` (not hardcoded).
   - `pull_request_target` triggers with untrusted code execution — high risk.
   - Overly broad permissions (`permissions: write-all`).
   - Unpinned third-party actions (use SHA pinning, not tag references).
   - Untrusted input (e.g., PR title, branch name) passed unsanitized to `run:` steps.

5. **Produce a findings report.**

   ```
   ## Security Review — PR #<N>

   ### Critical
   - **[Category]**: [Finding] — [File:line] — [Why it's a risk and suggested fix]

   ### High
   - ...

   ### Medium
   - ...

   ### Low / Informational
   - ...

   ### No Issues Found
   [Category] — No concerns identified.

   ## Summary
   Critical: N | High: N | Medium: N | Low: N
   ```

   Every audited category must appear in the report, even if no issues were found — list it under "No Issues Found" for completeness.

## Notes
- Read files before making claims — never flag an issue based solely on diff context.
- If a finding could be a false positive, note the uncertainty explicitly.
- Do not make code changes as part of this skill — findings only.
- For secrets: if a hardcoded secret is found, flag it as Critical and recommend immediate rotation regardless of whether the file is in `.gitignore`.
