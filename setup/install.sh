#!/usr/bin/env bash
# install.sh — symlink dotfiles into place on Linux/WSL
# Run from anywhere; resolves the repo root relative to this script.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTCONFIG="$REPO_ROOT/dotconfig"

# ── helpers ───────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[install]${NC} $*"; }
warn()  { echo -e "${YELLOW}[warn]${NC}    $*"; }
skip()  { echo -e "${YELLOW}[skip]${NC}    $*"; }
error() { echo -e "${RED}[error]${NC}   $*" >&2; }

# link <src> <dst>
# Creates a symlink at <dst> pointing to <src>.
# Backs up any existing non-symlink file/directory.
link() {
    local src="$1" dst="$2"

    if [ ! -e "$src" ]; then
        error "source not found: $src"
        return 1
    fi

    # Already correctly symlinked
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        skip "$dst → already linked"
        return 0
    fi

    # Dangling or wrong symlink — remove it
    if [ -L "$dst" ]; then
        warn "$dst is a stale/wrong symlink, removing"
        rm "$dst"
    fi

    # Existing real file/dir — back it up
    if [ -e "$dst" ]; then
        local backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
        warn "backing up $dst → $backup"
        mv "$dst" "$backup"
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$dst")"

    ln -s "$src" "$dst"
    info "$dst → $src"
}

# ── dotfiles ──────────────────────────────────────────────────────────────────

info "Linking dotfiles from $DOTCONFIG"

# git
link "$DOTCONFIG/git/.gitconfig"         "$HOME/.gitconfig"
link "$DOTCONFIG/git/.gitconfig-wsl"     "$HOME/.gitconfig-wsl"
link "$DOTCONFIG/git/xdg/ignore"         "$HOME/.config/git/ignore"

# bash
link "$DOTCONFIG/bash/.bashrc"           "$HOME/.bashrc"

# fish
link "$DOTCONFIG/fish/config.fish"       "$HOME/.config/fish/config.fish"

# zsh
link "$DOTCONFIG/zsh/.zshrc"            "$HOME/.zshrc"
link "$DOTCONFIG/zsh/.zprofile"         "$HOME/.zprofile"
link "$DOTCONFIG/zsh/.zshenv"           "$HOME/.zshenv"

# vim
link "$DOTCONFIG/vim/.vimrc"             "$HOME/.vimrc"

# nvim (whole directory)
link "$DOTCONFIG/nvim"                   "$HOME/.config/nvim"

# tmux
link "$DOTCONFIG/tmux/.tmux.conf"        "$HOME/.tmux.conf"

# ssh
link "$DOTCONFIG/ssh/config"             "$HOME/.ssh/config"
link "$DOTCONFIG/ssh/allowed_signers"    "$HOME/.ssh/allowed_signers"

# opencode
link "$DOTCONFIG/opencode"               "$HOME/.config/opencode"

# glab-cli
link "$DOTCONFIG/glab-cli/aliases.yml"  "$HOME/.config/glab-cli/aliases.yml"

# timewarrior
link "$DOTCONFIG/timewarrior/timewarrior.cfg" "$HOME/.config/timewarrior/timewarrior.cfg"

# ── done ──────────────────────────────────────────────────────────────────────

echo ""
info "Done. Reload your shell to pick up changes."
info "  fish: source ~/.config/fish/config.fish"
info "  zsh:  source ~/.zshrc"
info "  bash: source ~/.bashrc"
info ""
info "Note: glab-cli/config.yml is NOT symlinked — populate tokens with:"
info "  glab auth login --hostname devops.pnnl.gov"
info "  glab auth login --hostname infra-gitlab.pnl.gov"
info ""
info "Note: oh-my-posh theme (dotconfig/oh-my-posh/custom.omp.json) is backed"
info "  up here but lives at '/mnt/d/OneDrive - PNNL/Documents/custom.omp.json'"
info "  on the Windows side. Copy it there on a fresh machine."
