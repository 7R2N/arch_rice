#!/usr/bin/env bash
# touch-launch.sh <app> — launch an app from a lisgd touchscreen gesture.
#
# lisgd runs as root, so apps must NOT be spawned from here directly; instead
# ask Hyprland (running as the user) to exec them. XDG_RUNTIME_DIR and
# HYPRLAND_INSTANCE_SIGNATURE are passed inline by lisgd-start.sh.
#
# Fires only in tablet mode (Yoga fold switch) unless TOUCH_LAUNCH_ANYWHERE=1.
# Apps: launcher | terminal | browser | files

case "${1:-}" in
    launcher) cmd='wofi --show drun' ;;
    terminal) cmd='kitty' ;;
    browser)  cmd='firefox' ;;
    files)    cmd='dolphin' ;;
    *) echo "usage: ${0##*/} {launcher|terminal|browser|files}" >&2; exit 1 ;;
esac

if [[ "${TOUCH_LAUNCH_ANYWHERE:-0}" != 1 ]]; then
    for name in /sys/class/input/event*/device/name; do
        if grep -qi "tablet mode" "$name" 2>/dev/null; then
            dev="/dev/input/$(basename "$(dirname "$(dirname "$name")")")"
            evtest --query "$dev" EV_SW SW_TABLET_MODE
            [[ $? -eq 10 ]] || exit 0   # laptop mode: ignore the gesture
            break
        fi
    done
fi

exec hyprctl dispatch "hl.dsp.exec_cmd(\"$cmd\")"
