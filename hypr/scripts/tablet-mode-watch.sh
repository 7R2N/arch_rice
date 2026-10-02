#!/usr/bin/env bash
# Watches the Yoga tablet-mode switch and toggles squeekboard's auto-popup.
# Squeekboard runs as a D-Bus-activated systemd user service (mobi.phosh.OSK),
# so we don't start/kill the process — we flip the gsettings switch that
# controls whether it auto-shows when a text field is focused:
#   tablet mode -> auto-popup on (tap a textbox, keyboard appears)
#   laptop mode -> auto-popup off (Super+K can still force it)

# Single instance
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/tablet-mode-watch.lock"
flock -n 9 || exit 0

# Auto-detect the tablet-mode switch device (event number can change between boots)
SWITCH_DEV=""
for name in /sys/class/input/event*/device/name; do
    if grep -qi "tablet mode" "$name" 2>/dev/null; then
        SWITCH_DEV="/dev/input/$(basename "$(dirname "$(dirname "$name")")")"
        break
    fi
done

if [[ -z "$SWITCH_DEV" ]]; then
    notify-send "tablet-mode" "No tablet-mode switch device found" -u critical
    exit 1
fi

osk_on() {
    # lift the laptop-mode mask before anything tries to activate the service
    systemctl --user unmask --runtime mobi.phosh.OSK.service 2>/dev/null
    gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true
    # ensure squeekboard is running (D-Bus call activates the service if needed)
    busctl get-property --user sm.puri.OSK0 /sm/puri/OSK0 sm.puri.OSK0 Visible >/dev/null 2>&1
}

osk_off() {
    gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled false
    # hide it if it is currently on screen
    busctl call --user sm.puri.OSK0 /sm/puri/OSK0 sm.puri.OSK0 SetVisible b false 2>/dev/null
    # ...and actually stop it. The gsettings key alone is not enough: a running
    # squeekboard still reacts to any client activating text-input by mapping its
    # layer for ~40ms before hiding again. That flash claims a 400px exclusive
    # zone, so every window's bottom edge snaps up and back — very visible when
    # opening wofi (GTK clients poke the a11y/OSK bus name on startup).
    #
    # A plain `stop` does not hold: the unit is D-Bus activated and comes back
    # within a second or two. Mask it so nothing can activate it. --runtime keeps
    # the mask in /run, so it never persists across a reboot; this script sets the
    # correct state on startup anyway, and osk-toggle.sh unmasks for Super+K.
    systemctl --user mask --runtime --now mobi.phosh.OSK.service 2>/dev/null
}

# Apply the current state on startup (evtest --query exits 10 when the switch is active)
evtest --query "$SWITCH_DEV" EV_SW SW_TABLET_MODE
if [[ $? -eq 10 ]]; then osk_on; else osk_off; fi

# React to fold/unfold events (stdbuf: evtest block-buffers when piped, which delays events)
stdbuf -oL evtest "$SWITCH_DEV" 2>/dev/null | while read -r line; do
    case "$line" in
        *"SW_TABLET_MODE"*"value 1"*) osk_on ;;
        *"SW_TABLET_MODE"*"value 0"*) osk_off ;;
    esac
done
