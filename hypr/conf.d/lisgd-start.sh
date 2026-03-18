#!/usr/bin/env bash
# lisgd launcher for Hyprland touchscreen gestures
# Auto-detects the Wacom touchscreen device

# Find the touchscreen event device
TOUCH_DEV=""
for evdev in /sys/class/input/event*/device/name; do
    if grep -qi "Wacom.*Finger" "$evdev" 2>/dev/null; then
        TOUCH_DEV="/dev/input/$(basename "$(dirname "$(dirname "$evdev")")")"
        break
    fi
done

if [[ -z "$TOUCH_DEV" ]]; then
    notify-send "lisgd" "No touchscreen device found" -u critical
    exit 1
fi

# Kill any existing lisgd instance
sudo pkill -x lisgd 2>/dev/null
pkill -x lisgd 2>/dev/null
sleep 0.2

# Get screen dimensions for lisgd (avoids needing display access as root)
SCREEN_INFO=$(hyprctl monitors -j 2>/dev/null)
SCREEN_W=$(echo "$SCREEN_INFO" | grep -o '"width": [0-9]*' | head -1 | grep -o '[0-9]*')
SCREEN_H=$(echo "$SCREEN_INFO" | grep -o '"height": [0-9]*' | head -1 | grep -o '[0-9]*')

# Capture Hyprland socket info so hyprctl works when run as root
HIS="$HYPRLAND_INSTANCE_SIGNATURE"
XRD="$XDG_RUNTIME_DIR"
HYPRCTL="XDG_RUNTIME_DIR=$XRD HYPRLAND_INSTANCE_SIGNATURE=$HIS hyprctl"

# Launch lisgd with gesture bindings (3-finger swipes)
# -d device  -o orientation  -t threshold(px)  -r duration(ms)  -m timeoutMs  -w width  -h height
# Higher -t = need longer swipe to trigger, reduces false positives
exec sudo lisgd -d "$TOUCH_DEV" -o 0 -t 400 -r 20 -m 1500 -w "${SCREEN_W:-1920}" -h "${SCREEN_H:-1200}" \
    -g "3,LR,*,*,R,$HYPRCTL dispatch workspace e-1" \
    -g "3,RL,*,*,R,$HYPRCTL dispatch workspace e+1" \
    -g "3,DU,*,*,R,$HYPRCTL dispatch fullscreen 1" \
    -g "3,UD,*,*,R,$HYPRCTL dispatch togglefloating" \
    -g "4,UD,*,*,R,$HYPRCTL dispatch killactive"
