#!/usr/bin/env bash
set -euo pipefail
PROFILE_FILE="$HOME/.config/hypr/display-profile"

MODE=$(printf 'Laptop Only\nExtend\nExternal Only\n' | rofi -dmenu -i -p 'Display Mode') || exit 0
[[ -n "$MODE" ]] || exit 0

case "$MODE" in
    "Laptop Only") profile=laptop-only ;;
    "Extend") profile=extend ;;
    "External Only") profile=external-only ;;
    *) exit 0 ;;
esac

previous=$(cat "$PROFILE_FILE" 2>/dev/null || printf 'laptop-only')
printf '%s\n' "$profile" > "$PROFILE_FILE"
if ! hyprctl eval 'applyDisplayProfile()'; then
    printf '%s\n' "$previous" > "$PROFILE_FILE"
    notify-send -a 'Display switcher' 'Display profile failed' 'The previous monitor profile was restored.'
    exit 1
fi
notify-send -a 'Display switcher' 'Display profile applied' "$MODE"
