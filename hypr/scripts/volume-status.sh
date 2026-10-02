#!/usr/bin/env bash
# Waybar JSON status for the *real* output device.
#
# Waybar's pulseaudio module always follows the default sink, which is the
# EasyEffects virtual sink -- and that sink's volume never changes (see
# volume.sh). "ignored-sinks" only hides it, leaving the module blank, so
# report the resolved device ourselves instead.
#
# Runs continuously: prints once, then reprints on every PipeWire sink event.

set -eu

resolve() {
    local sink dev
    sink=$(pactl get-default-sink 2>/dev/null) || return 1
    if [ "$sink" = "easyeffects_sink" ]; then
        dev=$(sed -n 's/^outputDevice=//p' \
              "${XDG_CONFIG_HOME:-$HOME/.config}/easyeffects/db/easyeffectsrc" 2>/dev/null | head -1 || true)
        [ -n "${dev:-}" ] && sink="$dev"
    fi
    printf '%s' "$sink"
}

emit() {
    local sink vol muted desc icon text class
    sink=$(resolve) || { echo '{"text":"","class":"muted"}'; return; }
    vol=$(pactl get-sink-volume "$sink" 2>/dev/null | grep -oE '[0-9]+%' | head -1 | tr -d '%') || vol=0
    muted=$(pactl get-sink-mute "$sink" 2>/dev/null | awk '{print $2}') || muted=no
    desc=$(pactl list sinks 2>/dev/null \
           | awk -v s="$sink" '/^\tName: /{n=$2} /^\tDescription: /{if(n==s){sub(/^\tDescription: /,"");print;exit}}')

    if [ "$muted" = "yes" ]; then
        text=" muted"; class="muted"
    else
        if   [ "${vol:-0}" -lt 34 ]; then icon=""
        elif [ "${vol:-0}" -lt 67 ]; then icon=""
        else                              icon=""
        fi
        text="$icon ${vol}%"; class=""
    fi
    printf '{"text":"%s","class":"%s","tooltip":"%s | %s%%"}\n' \
           "$text" "$class" "${desc:-$sink}" "${vol:-0}"
}

emit
pactl subscribe 2>/dev/null | while read -r line; do
    case "$line" in
        *"on sink"*|*"on server"*) emit ;;
    esac
done
