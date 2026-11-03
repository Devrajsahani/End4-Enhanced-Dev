#!/usr/bin/env bash
# =============================================================================
# End4 Enhanced Dev - Automated Dotfiles Installer & Deployer
# =============================================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.local/share/dotfiles-backup-$(date +%Y%m%d%H%M%S)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  End4 Enhanced Dev - Dotfiles Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

backup_and_link() {
    local src="$1"
    local dest="$2"

    if [[ -e "$dest" && ! -L "$dest" ]]; then
        echo "  [backup] Backing up existing $dest -> $BACKUP_DIR/"
        mkdir -p "$BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
    elif [[ -L "$dest" ]]; then
        rm -f "$dest"
    fi

    mkdir -p "$(dirname "$dest")"
    echo "  [link]   $src -> $dest"
    ln -sf "$src" "$dest"
}

copy_or_link() {
    local src="$1"
    local dest="$2"
    mkdir -p "$(dirname "$dest")"
    echo "  [install] $dest"
    rsync -a "$src/" "$dest/"
}

# 1. Install user CLI scripts
echo "==> Installing custom scripts to ~/.local/bin..."
mkdir -p "$HOME/.local/bin"
for script in "$DOTFILES_DIR"/.local/bin/*; do
    if [[ -f "$script" ]]; then
        name="$(basename "$script")"
        install -m 755 "$script" "$HOME/.local/bin/$name"
    fi
done

# Create convenience aliases
ln -sf "$HOME/.local/bin/ii-control" "$HOME/.local/bin/ii-volume"
ln -sf "$HOME/.local/bin/ii-control" "$HOME/.local/bin/ii-brightness"

# 2. Deploy .config files
echo "==> Deploying configuration directories..."
for config in hypr quickshell/ii illogical-impulse kitty matugen wlogout cava fuzzel fish; do
    src="$DOTFILES_DIR/.config/$config"
    dest="$HOME/.config/$config"
    if [[ -d "$src" ]]; then
        mkdir -p "$(dirname "$dest")"
        if [[ ! -d "$dest" ]]; then
            rsync -a "$src/" "$dest/"
        else
            rsync -a --update "$src/" "$dest/"
        fi
    fi
done

# 3. Reload Hyprland and Quickshell if running
if command -v hyprctl >/dev/null 2>&1 && hyprctl monitors >/dev/null 2>&1; then
    echo "==> Reloading Hyprland configuration..."
    hyprctl reload || true
fi

if command -v qs >/dev/null 2>&1; then
    echo "==> Reloading Quickshell IPC..."
    qs -c ii ipc call reload || true
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation Complete!"
echo "  Explore keybindings: press Super + / or Super + Alt + K"
echo "  Explore quick controls: press Super + Alt + C"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

