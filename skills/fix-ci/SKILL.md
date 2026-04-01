---
name: fix-ci
description: Diagnose and fix failing GitHub Actions CI checks for a pull request. Use this skill whenever CI is failing, GitHub Actions checks are red, a build is broken, or the user says "fix CI", "the checks are failing", "CI is broken", or "why is the build failing".
user_invocable: true
---

Diagnose and fix failing GitHub Actions CI checks for a pull request.

## Steps

1. **Resolve the PR number.** If `$ARGUMENTS` contains a number, use it as the PR number. Otherwise, detect the current branch with `git branch --show-current` and resolve the PR number by running `gh pr view --json number --jq .number`. If no open PR is found, stop and tell the user to open a PR first or pass a PR number explicitly.

2. **Fetch check status.** Run `gh pr checks <PR_NUMBER>` and parse the output. Classify each check into one of these buckets:
   - **failing** — status is "fail" or "X"
   - **skipped / not fixable** — the check name contains `claude-review`, `db-integration`, or `vercel` (case-insensitive). Report these as skipped.
   - **passing** — no action needed.
   If every check is passing or skipped, report "All fixable checks are green" and stop.

3. **Fetch failure logs.** For each failing check, find the corresponding workflow run ID with `gh run list --branch <BRANCH> --workflow <WORKFLOW_FILE> --limit 1 --json databaseId --jq '.[0].databaseId'` and download logs via `gh run view <RUN_ID> --log-failed`. Note which step failed and the error output.

4. **Apply targeted fixes per check type.** Process each failing check below. Skip sections for passing checks.

---

### 4a. DB Verification / db-static

This check runs `scripts/db/check-migrations.sh`. It validates:
- Every `.sql` file in `supabase/migrations/` has a 4-digit numeric prefix.
- Prefixes are strictly sequential starting from `0001` with no gaps.
- Required content patterns exist in specific files:
  - `0006_forecasts.sql` must contain `partition by range (forecast_at)`
  - `0008_notifications.sql` must contain `partition by range (created_at)`
  - `0010_rls_policies.sql` must contain `enable row level security`
  - `0012_retention_jobs.sql` must contain `create or replace function public.ensure_daily_partitions`

**To fix:**
1. Read `scripts/db/check-migrations.sh` to confirm validation rules.
2. List `supabase/migrations/` and check naming and ordering.
3. Rename any misnumbered files to restore sequential 4-digit prefixes.
4. If a required content pattern is missing, read that migration file and add/correct the SQL.
5. Verify locally: `npm run db:check:migrations`.

---

### 4b. Onboarding E2E / onboarding-e2e

This check runs `npx tsc --noEmit` then `npm run test:e2e:ci`. Typecheck failures block E2E, so fix typecheck first.

**To fix typecheck errors:**
1. Run `npx tsc --noEmit` locally and read all errors.
2. For each error, read the offending file and line, understand the type mismatch, apply the fix.
3. Re-run `npx tsc --noEmit` to confirm zero errors.

**To fix E2E failures (only if typecheck passes):**
1. Read the failed log from step 3 to identify which test case failed.
2. Read the failing test file under `tests/e2e/`.
3. Read the application source files referenced by the test.
4. Fix either the test expectation or the underlying application bug as appropriate.
5. Note: full E2E re-run requires a local Supabase stack. Flag any infrastructure-dependent failures to the user.

---

### 4c. Design System Checks / design-system

This check runs six sub-checks in order. Work through them in sequence — a failure in an earlier step blocks later steps in CI.

**Lint:** Run `npm run lint`. Fix violations; run `npx eslint --fix` for auto-fixable issues.

**Build:** Run `npm run build`. Fix compilation errors.

**Token drift:** Run `npm run tokens:check`. If it fails, run `npm run tokens:export` to regenerate, then re-check.

**Contrast:** Run `npm run contrast:check`. Read `scripts/design-system/check-contrast.mjs` for the failing pairs and required ratios. Adjust color tokens to meet WCAG 4.5:1 minimum.

**A11y contracts:** Run `npm run a11y:check`. Read `scripts/design-system/check-a11y.mjs` to see which component contracts are violated. Fix missing ARIA attributes, roles, or min-height rules in the offending component files.

**Parity drift:** Run `npm run parity:check`. If it fails, run `npm run parity:generate` to regenerate, then re-check.

---

### 4d. Spot Catalog E2E / spot-catalog-e2e

This check runs `npm run test:e2e:spot-catalog` against a seeded local Supabase stack. Unlike `onboarding-e2e`, it does **not** run a typecheck step first.

> **Note:** This check is path-triggered — it only fires when spot-catalog-related files are modified. If it appears in failing checks, a relevant file change triggered it.

**To fix E2E failures:**
1. Read the failed log from step 3 to identify the failing test case.
2. Read `tests/e2e/spot-catalog.spec.ts`.
3. Read referenced source files: `app/spot-catalog/page.tsx`, `lib/spots.ts`, `components/design-system/spot-card.tsx`.
4. Fix either the test expectation or the underlying application bug as appropriate.
5. If the failure is in seed data or DB setup, check `scripts/db/seed-spots.sh` and `supabase/migrations/0011_seed_spots_oahu.sql`.
6. Note: full re-run requires a local Supabase stack. Flag any infrastructure-dependent failures to the user.

---

5. **Summary.** After all fixes are applied, report:
   - Which checks were failing and what was fixed for each.
   - Which checks were skipped (claude-review, db-integration, Vercel) and why.
   - All files modified.
   - Remind the user: "Changes are NOT committed. Review the diffs and commit when ready."
