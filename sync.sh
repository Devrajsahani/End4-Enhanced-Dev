#!/usr/bin/env bash
# Sync active configs from $HOME into this repository
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Syncing dotfiles into $REPO_DIR..."

# .config/hypr
mkdir -p "$REPO_DIR/.config/hypr"
rsync -av --delete \
    --exclude=".git" \
    --exclude=".agents" \
    --exclude=".aws" \
    --exclude=".codex" \
    --exclude="*.bak" \
    --exclude="*.backup-*" \
    "$HOME/.config/hypr/" "$REPO_DIR/.config/hypr/"

# .config/quickshell/ii
mkdir -p "$REPO_DIR/.config/quickshell/ii"
rsync -av --delete \
    --exclude=".git" \
    --exclude=".agents" \
    --exclude=".aws" \
    --exclude=".codex" \
    --exclude="*.bak" \
    --exclude="*.backup-*" \
    "$HOME/.config/quickshell/ii/" "$REPO_DIR/.config/quickshell/ii/"

# .config/illogical-impulse
mkdir -p "$REPO_DIR/.config/illogical-impulse"
rsync -av --delete \
    --exclude=".git" \
    --exclude="*.bak" \
    --exclude="*.backup-*" \
    --exclude="backup-*" \
    "$HOME/.config/illogical-impulse/" "$REPO_DIR/.config/illogical-impulse/"

# .config/kitty, matugen, wlogout, cava, fuzzel, fish
for dir in kitty matugen wlogout cava fuzzel fish; do
    if [[ -d "$HOME/.config/$dir" ]]; then
        mkdir -p "$REPO_DIR/.config/$dir"
        rsync -av --delete \
            --exclude=".git" \
            --exclude="*.bak" \
            --exclude="*.backup-*" \
            "$HOME/.config/$dir/" "$REPO_DIR/.config/$dir/"
    fi
done

# .config individual files
if [[ -f "$HOME/.config/claude-desktop-flags.conf" ]]; then
    cp -p "$HOME/.config/claude-desktop-flags.conf" "$REPO_DIR/.config/"
fi

# .local/bin custom scripts
mkdir -p "$REPO_DIR/.local/bin"
for script in ii-anim ii-audio ii-bar-layout ii-control ii-display ii-keybinds ii-slider ii-spotlight ii-theme ii-github-fetch ii-leetcode-fetch; do
    if [[ -f "$HOME/.local/bin/$script" ]]; then
        cp -p "$HOME/.local/bin/$script" "$REPO_DIR/.local/bin/"
    fi
done

echo "==> Sync complete!"
