#!/usr/bin/env bash
# Bootstraps this dotfiles repo onto a new machine.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(brew helix ghostty zsh herdr pi agent-skills claude)

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required: https://brew.sh"
  exit 1
fi

if ! command -v stow >/dev/null 2>&1; then
  echo "Installing GNU Stow..."
  brew install stow
fi

cd "$DOTFILES_DIR"
stow -v -t "$HOME" "${PACKAGES[@]}"

echo "Installing Homebrew packages from .Brewfile..."
brew bundle --global

echo
echo "Done. A few things stow can't do for you:"
echo "  - zim modules install on first shell start (see .zshrc)."
echo "  - Restore agent skills from the lockfile:"
echo "      npx skills experimental_install -g"
echo "  - pi's auth.json and Claude Code's OAuth state are deliberately not"
echo "    tracked here; log in again on this machine."
