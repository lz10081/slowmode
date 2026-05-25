#!/usr/bin/env bash
# Slowmode — install helper
# Usage: ./scripts/install.sh <target> [destination]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RAW_BASE="https://raw.githubusercontent.com/lz10081/slowmode/main"

usage() {
  cat <<'EOF'
Slowmode install helper

Targets:
  cursor-rule     Copy .mdc into .cursor/rules/ (default: current directory)
  cursor-skill    Copy skill to ~/.cursor/skills/hardcore-dev-harness/
  project-skill   Copy skill to .cursor/skills/hardcore-dev-harness/ in cwd
  claude-md       Copy CLAUDE.md into destination (default: cwd)
  amp-skill       Clone repo and symlink for Amp (~/.config/amp/skills/)
  templates       Copy FEATURES.md + CONTRACT.md templates into cwd

Examples:
  ./scripts/install.sh cursor-rule
  ./scripts/install.sh cursor-skill
  ./scripts/install.sh claude-md /path/to/my-app
  ./scripts/install.sh amp-skill
  ./scripts/install.sh templates

Remote install (no clone):
  curl -fsSL https://raw.githubusercontent.com/lz10081/slowmode/main/scripts/install.sh | bash -s -- cursor-rule

Environment:
  SLOWMODE_REPO  Override local repo path (default: script parent directory)
EOF
}

die() { echo "error: $*" >&2; exit 1; }

install_cursor_rule() {
  local dest="${1:-.}"
  mkdir -p "$dest/.cursor/rules"
  cp "$REPO_ROOT/.cursor/rules/hardcore-dev-harness.mdc" "$dest/.cursor/rules/"
  echo "Installed: $dest/.cursor/rules/hardcore-dev-harness.mdc"
  echo "Tip: In Cursor, enable the rule for your project or @-mention hardcore-dev-harness."
}

install_cursor_skill() {
  local skill_dir="${HOME}/.cursor/skills/hardcore-dev-harness"
  mkdir -p "${HOME}/.cursor/skills"
  rm -rf "$skill_dir"
  cp -R "$REPO_ROOT/skills/hardcore-dev-harness" "$skill_dir"
  echo "Installed: $skill_dir/SKILL.md"
  echo "Tip: Agent picks up skills from ~/.cursor/skills/ automatically when relevant."
}

install_project_skill() {
  local dest="${1:-.}"
  mkdir -p "$dest/.cursor/skills"
  rm -rf "$dest/.cursor/skills/hardcore-dev-harness"
  cp -R "$REPO_ROOT/skills/hardcore-dev-harness" "$dest/.cursor/skills/"
  echo "Installed: $dest/.cursor/skills/hardcore-dev-harness/SKILL.md"
}

install_claude_md() {
  local dest="${1:-.}"
  cp "$REPO_ROOT/CLAUDE.md" "$dest/CLAUDE.md"
  echo "Installed: $dest/CLAUDE.md"
  echo "For Codex/OpenAI agents, copy or symlink to AGENTS.md if your stack expects that filename."
}

install_amp_skill() {
  local amp_root="${HOME}/.config/amp/skills"
  local clone_dir="${amp_root}/_slowmode"
  mkdir -p "$amp_root"
  if [[ -d "$clone_dir/.git" ]]; then
    git -C "$clone_dir" pull --ff-only
  else
    git clone https://github.com/lz10081/slowmode.git "$clone_dir"
  fi
  ln -sfn "$clone_dir/skills/hardcore-dev-harness" "${amp_root}/hardcore-dev-harness"
  echo "Installed Amp skill: ${amp_root}/hardcore-dev-harness -> ${clone_dir}/skills/hardcore-dev-harness"
}

install_templates() {
  local dest="${1:-.}"
  mkdir -p "$dest/templates"
  cp "$REPO_ROOT/templates/FEATURES.md" "$dest/FEATURES.md"
  cp "$REPO_ROOT/templates/CONTRACT.md" "$dest/templates/CONTRACT.md"
  echo "Installed: $dest/FEATURES.md and $dest/templates/CONTRACT.md"
}

main() {
  local target="${1:-}"
  local dest="${2:-.}"
  REPO_ROOT="${SLOWMODE_REPO:-$REPO_ROOT}"

  case "${target}" in
    -h|--help|help|"") usage; exit 0 ;;
    cursor-rule)     install_cursor_rule "$dest" ;;
    cursor-skill)    install_cursor_skill ;;
    project-skill)   install_project_skill "$dest" ;;
    claude-md)       install_claude_md "$dest" ;;
    amp-skill)       install_amp_skill ;;
    templates)       install_templates "$dest" ;;
    *)
      die "unknown target: $target (run with --help)"
      ;;
  esac
}

main "$@"
