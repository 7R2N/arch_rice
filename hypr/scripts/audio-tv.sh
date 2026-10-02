#!/usr/bin/env bash
# Re-arm the TV audio split after the HDMI sink appears.
#
# Target layout: Firefox on the TV (raw, no EQ), everything else through
# EasyEffects into the laptop speakers. Two things make that work:
#
#   1. Firefox is on the blocklist of every EasyEffects preset. Without it
#      EasyEffects (process-all-outputs) yanks the stream back into its own
#      sink within a second or two, and no amount of pactl move sticks.
#   2. WirePlumber remembers a per-application target, so once Firefox has
#      been moved to the HDMI sink it stays there across restarts -- and when
#      the TV is unplugged the target is gone, so it falls back to the default
#      sink (easyeffects_sink) and gets the EQ again. That fallback needs no
#      help from this script.
#
# The catch this script exists for: EasyEffects only re-reads the blocklist
# when a preset is loaded. Streams already running when the TV is plugged in
# were claimed before the blocklist applied to them, so the preset has to be
# reloaded before the move will hold.

set -eu

hdmi=$(pactl list short sinks | awk '/hdmi-stereo/ {print $2; exit}')
[ -n "${hdmi:-}" ] || { echo "no HDMI sink -- nothing to do" >&2; exit 0; }

ee="${XDG_CONFIG_HOME:-$HOME/.config}/easyeffects/db/easyeffectsrc"
preset=$(sed -n 's/^lastLoadedOutputPreset=//p' "$ee" 2>/dev/null | head -1 || true)
[ -n "${preset:-}" ] && easyeffects -l "$preset" >/dev/null 2>&1 && sleep 2

pactl list sink-inputs |
    awk '/Sink Input #/ {i = substr($3, 2)} /application\.name = "Firefox"/ {print i}' |
    while read -r id; do
        pactl move-sink-input "$id" "$hdmi"
    done
