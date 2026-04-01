#!/usr/bin/env bash
# install.sh — copies dvl-ops skills into the consuming project's .claude/skills/
#
# Run from the root of the consuming project:
#   bash .claude/dvl-ops/install.sh
#
# Or after a submodule update:
#   git submodule update --remote .claude/dvl-ops && bash .claude/dvl-ops/install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(pwd)/.claude/skills"

if [ ! -d "$TARGET_DIR" ]; then
  mkdir -p "$TARGET_DIR"
fi

echo "Installing dvl-ops skills into $TARGET_DIR ..."

for skill_dir in "$SCRIPT_DIR/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  dest="$TARGET_DIR/$skill_name"

  if [ -d "$dest" ]; then
    # Skip if the destination SKILL.md differs from the plugin source —
    # this means the project has a custom override for this skill.
    if [ -f "$dest/SKILL.md" ] && ! diff -q "$skill_dir/SKILL.md" "$dest/SKILL.md" > /dev/null 2>&1; then
      echo "  Skipping  $skill_name (project override present)"
      continue
    fi
    echo "  Updating  $skill_name"
  else
    echo "  Installing $skill_name"
    mkdir -p "$dest"
  fi

  cp "$skill_dir/SKILL.md" "$dest/SKILL.md"
done

echo "Done. $(ls "$SCRIPT_DIR/skills" | wc -l | tr -d ' ') skills installed."
echo ""
echo "Next steps:"
echo "  git add .claude/skills"
echo "  git commit -m 'install dvl-ops skills'"
