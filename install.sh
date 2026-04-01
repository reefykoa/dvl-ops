#!/usr/bin/env bash
# install.sh — copies dvl-ops skills into the consuming project's .claude/skills/
#
# Run from the root of the consuming project:
#   bash .claude/dvl-ops/install.sh
#
# Or after a submodule update:
#   git submodule update --remote .claude/dvl-ops && bash .claude/dvl-ops/install.sh
#
# Project overrides: if a skill's SKILL.md was NOT installed by dvl-ops (no .dvl-ops marker
# file alongside it), install.sh will skip it rather than clobber it. This lets projects
# maintain customised versions of any skill without losing them on updates.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(pwd)/.claude/skills"

if [ ! -d "$TARGET_DIR" ]; then
  mkdir -p "$TARGET_DIR"
fi

# Also copy shared support files (_shared/) so skills that reference them can read them.
SHARED_SRC="$SCRIPT_DIR/skills/_shared"
SHARED_DEST="$TARGET_DIR/_shared"
if [ -d "$SHARED_SRC" ]; then
  mkdir -p "$SHARED_DEST"
  cp -r "$SHARED_SRC"/. "$SHARED_DEST/"
fi

echo "Installing dvl-ops skills into $TARGET_DIR ..."

skill_count=0

for skill_dir in "$SCRIPT_DIR/skills"/*/; do
  skill_name="$(basename "$skill_dir")"

  # Skip support directories (prefixed with _)
  [[ "$skill_name" == _* ]] && continue

  dest="$TARGET_DIR/$skill_name"

  if [ -d "$dest" ]; then
    if [ ! -f "$dest/.dvl-ops" ]; then
      # No marker — this skill was not installed by dvl-ops; it is a project override.
      echo "  Skipping  $skill_name (project override — no .dvl-ops marker)"
      continue
    fi
    echo "  Updating  $skill_name"
  else
    echo "  Installing $skill_name"
    mkdir -p "$dest"
  fi

  cp "$skill_dir/SKILL.md" "$dest/SKILL.md"
  # Write marker so future runs know this skill is dvl-ops managed.
  touch "$dest/.dvl-ops"

  skill_count=$((skill_count + 1))
done

echo "Done. $skill_count skills installed/updated."
echo ""
echo "Next steps:"
echo "  git add .claude/skills"
echo "  git commit -m 'install dvl-ops skills'"
