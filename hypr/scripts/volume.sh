#!/usr/bin/env bash
# Volume / mute for the *real* output device.
#
# EasyEffects presents a virtual sink ("easyeffects_sink"). It accepts volume
# changes but never applies them -- there is no hardware mixer behind it, so
# PipeWire leaves softVolumes at 1.0 and the level is silently discarded.
# Targeting @DEFAULT_AUDIO_SINK@ therefore moves a number that controls nothing.
# So: if the default sink is the EasyEffects one, resolve past it to the device
# EasyEffects is actually feeding (which it records in its own config).

set -eu

sink=$(pactl get-default-sink)
if [ "$sink" = "easyeffects_sink" ]; then
    ee="${XDG_CONFIG_HOME:-$HOME/.config}/easyeffects/db/easyeffectsrc"
    dev=$(sed -n 's/^outputDevice=//p' "$ee" 2>/dev/null | head -1 || true)
    [ -n "${dev:-}" ] && sink="$dev"
fi

step="${2:-5}"

case "${1:-}" in
    up|down)
        cur=$(pactl get-sink-volume "$sink" | grep -oE '[0-9]+%' | head -1 | tr -d '%')
        if [ "$1" = "up" ]; then new=$((cur + step)); else new=$((cur - step)); fi
        [ "$new" -gt 100 ] && new=100          # cap, matches wpctl -l 1
        [ "$new" -lt 0 ] && new=0
        pactl set-sink-volume "$sink" "${new}%"
        ;;
    mute)
        pactl set-sink-mute "$sink" toggle
        ;;
    get)
        printf '%s %s\n' "$sink" "$(pactl get-sink-volume "$sink" | grep -oE '[0-9]+%' | head -1)"
        ;;
    *)
        echo "usage: ${0##*/} {up|down|mute|get} [step]" >&2
        exit 1
        ;;
esac
