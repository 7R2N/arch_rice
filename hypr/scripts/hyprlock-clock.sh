#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# hyprlock-clock.sh — theme-aware clock for lock screen
# Place at: ~/.config/hypr/scripts/hyprlock-clock.sh
# chmod +x
#
# Reads current theme from ~/.config/hypr/.current-theme
# and displays time with kanji (samurai) or Arabic (arabic).
# ═══════════════════════════════════════════════════════════

THEME_STATE="$HOME/.config/hypr/.current-theme"
THEME=$(cat "$THEME_STATE" 2>/dev/null || echo "arabic")

hour=$(date +%H)
time=$(date +"%I:%M")

case "$THEME" in
    samurai)
        if (( 10#$hour >= 6 && 10#$hour < 18 )); then
            echo "昼  $time"
        else
            echo "夜  $time"
        fi
        ;;
    arabic)
        if (( 10#$hour >= 6 && 10#$hour < 18 )); then
            echo "نهار  $time"
        else
            echo "ليل  $time"
        fi
        ;;
    *)
        echo "$time"
        ;;
esac
