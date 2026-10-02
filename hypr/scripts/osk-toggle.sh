#!/usr/bin/env bash
# Super+K: force-show/hide the squeekboard on-screen keyboard in any mode.
# The busctl calls D-Bus-activate squeekboard's systemd service if it is
# not already running, so no manual process management is needed.

VISIBLE=$(busctl get-property --user sm.puri.OSK0 /sm/puri/OSK0 sm.puri.OSK0 Visible 2>/dev/null | awk '{print $2}')
if [[ "$VISIBLE" == "true" ]]; then
    busctl call --user sm.puri.OSK0 /sm/puri/OSK0 sm.puri.OSK0 SetVisible b false
else
    # In laptop mode tablet-mode-watch.sh masks the unit (a running squeekboard
    # flashes its 400px layer whenever any client touches text-input, which jolts
    # every window). Lift the mask so an explicit Super+K can still force it up.
    if [[ "$(systemctl --user is-enabled mobi.phosh.OSK.service 2>&1)" == masked* ]]; then
        systemctl --user unmask --runtime mobi.phosh.OSK.service 2>/dev/null
        systemctl --user start mobi.phosh.OSK.service 2>/dev/null
        # wait for it to own the bus name, else SetVisible races the cold start
        for _ in {1..20}; do
            busctl get-property --user sm.puri.OSK0 /sm/puri/OSK0 sm.puri.OSK0 Visible \
                >/dev/null 2>&1 && break
            sleep 0.1
        done
        # owning the name is still too early — squeekboard drops a SetVisible that
        # arrives before its panel is ready ("no request is pending. Ignoring")
        sleep 0.4
    fi
    busctl call --user sm.puri.OSK0 /sm/puri/OSK0 sm.puri.OSK0 SetVisible b true
    # ...and confirm it actually came up, retrying once if the request was dropped
    for _ in {1..10}; do
        [[ "$(busctl get-property --user sm.puri.OSK0 /sm/puri/OSK0 sm.puri.OSK0 Visible \
              2>/dev/null | awk '{print $2}')" == "true" ]] && exit 0
        sleep 0.1
    done
    busctl call --user sm.puri.OSK0 /sm/puri/OSK0 sm.puri.OSK0 SetVisible b true
fi
