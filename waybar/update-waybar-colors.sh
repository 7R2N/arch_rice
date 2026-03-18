#!/usr/bin/env bash
# ─── update-waybar-colors.sh ───
# Extracts colors from the current wallpaper and applies them to waybar.
# Automatically detects wallpaper from hyprpaper config.
#
# Usage (no arguments needed):
#   ~/.config/waybar/update-waybar-colors.sh
#
# Or specify a wallpaper explicitly:
#   ~/.config/waybar/update-waybar-colors.sh /path/to/image.png

COLORS_FILE="$HOME/.cache/wal/colors"
OUTPUT="$HOME/.config/waybar/colors.css"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"
BACKEND="haishoku"   # haishoku captures dominant/vibrant colors best

# ── 1. Determine wallpaper path ──
if [[ -n "$1" ]]; then
  WALLPAPER="$1"
elif [[ -f "$HYPRPAPER_CONF" ]]; then
  # Parse "path = /some/file" from hyprpaper.conf
  WALLPAPER=$(grep -oP '^\s*path\s*=\s*\K\S+' "$HYPRPAPER_CONF" | head -1)
fi

if [[ -z "$WALLPAPER" || ! -f "$WALLPAPER" ]]; then
  echo "Could not find wallpaper."
  echo "  • Checked hyprpaper config: ${HYPRPAPER_CONF:-none}"
  echo "  • Resolved path: ${WALLPAPER:-<empty>}"
  echo "Tip: pass the wallpaper path as an argument."
  exit 1
fi

echo "Wallpaper: $WALLPAPER"

# ── 2. Extract colors with pywal ──
if ! command -v wal &>/dev/null; then
  echo "pywal not found. Install it: pip install pywal"
  exit 1
fi

wal -i "$WALLPAPER" --backend "$BACKEND" -n -e -q   # -n = no wallpaper set, -e = no reload, -q = quiet

if [[ ! -f "$COLORS_FILE" ]]; then
  echo "pywal failed to generate colors at $COLORS_FILE"
  exit 1
fi

# ── 3. Generate waybar colors.css ──
mapfile -t C < "$COLORS_FILE"

cat > "$OUTPUT" <<EOF
/* Auto-generated from pywal — do not edit manually */
/* Source wallpaper: $WALLPAPER */
@define-color bg      ${C[0]};
@define-color fg      ${C[7]};
@define-color accent1 ${C[4]};
@define-color accent2 ${C[2]};
@define-color accent3 ${C[3]};
@define-color accent4 ${C[6]};
@define-color accent5 ${C[1]};
@define-color accent6 ${C[5]};
EOF

echo "Wrote waybar colors to $OUTPUT"

# ── 4. Reload waybar ──
if pgrep -x waybar &>/dev/null; then
  killall -SIGUSR2 waybar 2>/dev/null && echo "Waybar reloaded." || echo "Could not signal waybar."
else
  echo "Waybar is not running."
fi
