----------------------------
---- TOUCHSCREEN GESTURES ----
----------------------------

-- Uses lisgd — a lightweight touchscreen gesture daemon
-- Device: Wacom HID 52C6 Finger (/dev/input/event9)
--
-- Gestures:
--   3-finger swipe left/right → switch workspace
--   3-finger swipe up         → maximize (fullscreen)
--   3-finger swipe down       → toggle floating
--   4-finger swipe down       → close window
--
-- Note: the event device number may change after reboot.
-- The script below auto-detects the device.

hl.on("hyprland.start", function()
    hl.exec_cmd("/home/trzn/.config/hypr/scripts/lisgd-start.sh")

    -- Tablet mode: watch the Yoga fold switch — in tablet mode squeekboard runs and
    -- auto-shows the on-screen keyboard when a text field is focused
    hl.exec_cmd("/home/trzn/.config/hypr/scripts/tablet-mode-watch.sh")
end)
