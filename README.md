# dvl-ops

Cross-project Claude Code skills for Digital Vortex Labs teams. These skills automate the shared developer operations workflow — PR creation, code review response, push flows, and issue validation — and can be used in any DVL project.

## Skills

| Skill | Purpose |
|-------|---------|
| [`open-pr`](skills/open-pr/SKILL.md) | Stage, commit, push, create a PR, and request CodeRabbit review |
| [`push-up-changes`](skills/push-up-changes/SKILL.md) | Stage relevant files, commit, and push the current branch |
| [`address-review-feedback`](skills/address-review-feedback/SKILL.md) | Apply fixes for PR review comments and post a structured reply |
| [`post-review-followup`](skills/post-review-followup/SKILL.md) | Summarize how each piece of reviewer feedback was handled |
| [`address-coderabbit-feedback`](skills/address-coderabbit-feedback/SKILL.md) | Fix unresolved CodeRabbit threads and reply inline |
| [`validate-pr-against-issue`](skills/validate-pr-against-issue/SKILL.md) | Compare a Linear issue against a PR and report requirement gaps |

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
2. Open a PR — CodeRabbit will review automatically.
3. After merge, consuming projects bump their submodule ref via `git submodule update --remote`.
