#!/usr/bin/env bash
# rendermill install-skill — make the render pipeline loadable as a Hermes
# skill (spec §5.8 port; same shape as the consumer skill installer).
# Usage: bash install-skill.sh [target-skills-dir]
# Default target: ~/.hermes/skills (the default profile's skill dir).
# Any skill-dir-shaped target works (e.g. ~/.hermes/shared-skills for
# fleet-wide visibility across profiles).
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-$HOME/.hermes/skills}"
DEST="$TARGET/rendermill"

say() { printf '[install-skill] %s\n' "$*"; }

if [ ! -f "$HERE/skills/rendermill/SKILL.md" ]; then
  say "FATAL: skills/rendermill/SKILL.md not found in repo"; exit 1
fi

mkdir -p "$TARGET"
if [ -e "$DEST" ]; then
  rm -rf "$DEST"
  say "replaced existing $DEST"
fi
cp -R "$HERE/skills/rendermill" "$DEST"
say "installed skill -> $DEST"

# the skill body references the repo; embed the resolved path so sessions
# find the tools regardless of cwd
printf '\n<!-- resolved repo path: %s -->\n' "$HERE" >> "$DEST/SKILL.md"
say "repo path pinned: $HERE"

if [ -d "$HOME/.claude" ]; then
  mkdir -p "$HOME/.claude/skills"
  rm -rf "$HOME/.claude/skills/rendermill"
  cp -R "$HERE/skills/rendermill" "$HOME/.claude/skills/rendermill"
  printf '\n<!-- resolved repo path: %s -->\n' "$HERE" >> "$HOME/.claude/skills/rendermill/SKILL.md"
  say "Claude Code refreshed -> ~/.claude/skills/rendermill"
fi
say ""
say "verify: $HERE/.venv/bin/python -m pytest $HERE/tests -q"