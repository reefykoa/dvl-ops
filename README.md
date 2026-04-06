# dvl-ops

Cross-project Claude Code skills for Digital Vortex Labs teams. These skills automate the shared developer operations workflow — PR creation, code review response, push flows, and issue validation — and can be used in any DVL project.

## Skills

### PR & Code Review

| Skill | Purpose |
|-------|---------|
| [`open-pr`](skills/open-pr/SKILL.md) | Stage, commit, push, and create a PR |
| [`push-up-changes`](skills/push-up-changes/SKILL.md) | Stage relevant files, commit, and push the current branch |
| [`analyze-review-feedback`](skills/analyze-review-feedback/SKILL.md) | Pre-flight analysis of review comments — priority and recommendation, no code changes |
| [`address-review-feedback`](skills/address-review-feedback/SKILL.md) | Apply fixes for PR review comments and post a structured reply |
| [`reply-to-conversations`](skills/reply-to-conversations/SKILL.md) | Post individual in-thread replies to a list of GitHub conversation URLs |
| [`post-review-followup`](skills/post-review-followup/SKILL.md) | Summarize how each piece of reviewer feedback was handled |
| [`validate-pr-against-issue`](skills/validate-pr-against-issue/SKILL.md) | Compare a Linear issue against a PR and report requirement gaps |
| [`summarize-pr`](skills/summarize-pr/SKILL.md) | Generate dual TLDR summaries (stakeholder + engineering) for a PR |
| [`post-analysis-to-github`](skills/post-analysis-to-github/SKILL.md) | Post the current conversation's analysis as a GitHub PR comment |

### CI & Testing

| Skill | Purpose |
|-------|---------|
| [`fix-unit-tests`](skills/fix-unit-tests/SKILL.md) | Run unit tests, fix all failures, and loop until green |
| [`run-test-plan`](skills/run-test-plan/SKILL.md) | Execute a test plan checklist from a Linear issue comment and post results |

### Investigation & Analysis

| Skill | Purpose |
|-------|---------|
| [`investigate-linear-issue`](skills/investigate-linear-issue/SKILL.md) | End-to-end Linear issue investigation — posts 8-section analysis as a comment |
| [`investigate-slack-threads`](skills/investigate-slack-threads/SKILL.md) | Root cause investigation starting from raw Slack thread URLs |

### Security

| Skill | Purpose |
|-------|---------|
| [`security-review-pr`](skills/security-review-pr/SKILL.md) | Audit a PR for OWASP Top 10, hardcoded secrets, injection risks, and CI/CD misuse |

### Documentation

| Skill | Purpose |
|-------|---------|
| [`summarize-document`](skills/summarize-document/SKILL.md) | Generate dual summaries (non-technical + engineering) for any document or text |
| [`sync-project-docs`](skills/sync-project-docs/SKILL.md) | Update project plan markdown docs to reflect current Linear + GitHub + repo state |

## Adding to a Project

### Option A: Git Submodule (recommended — auto-updates with `git submodule update`)

```bash
# From the root of your project:
git submodule add https://github.com/reefykoa/dvl-ops .claude/dvl-ops
git submodule update --init --recursive
```

Then run the install script to copy skills into `.claude/skills/`:

```bash
bash .claude/dvl-ops/install.sh
```

To update to the latest skills after changes are merged to `dvl-ops`:

```bash
git submodule update --remote .claude/dvl-ops
bash .claude/dvl-ops/install.sh
git add .claude/dvl-ops .claude/skills
git commit -m "update dvl-ops skills"
```

### Option B: Manual copy

Copy individual `skills/<skill-name>/SKILL.md` files into your project's `.claude/skills/` directory.

## Project-Specific Skills

Each project maintains its own skills in `.claude/skills/` for workflows that are tightly coupled to that codebase. See each project's `docs/skills.md` for the full inventory.

## Contributing

1. Add or update a `skills/<skill-name>/SKILL.md` in this repo.
2. Open a PR for review.
3. After merge, consuming projects bump their submodule ref via `git submodule update --remote`.
