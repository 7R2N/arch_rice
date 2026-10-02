-- Hyprland Lua config — converted from hyprland.conf + conf.d/* (hyprlang was
-- deprecated in 0.55; .conf support is being removed).
-- Refer to https://wiki.hypr.land/Configuring/Start/
--
-- Split across files, mirroring the old conf.d layout:
--   conf/my_programs.lua  — terminal / file manager / launcher
--   conf/keybinds.lua     — all keybindings
--   conf/touchpad.lua     — touchpad gestures
--   conf/touchscreen.lua  — lisgd + tablet-mode autostart
-- (Directory is "conf" not "conf.d" — Lua's require() treats "." as a
--  directory separator, so a dot in the dir name would break resolution.)

local programs = require("conf/my_programs")
require("conf/keybinds")
require("conf/touchpad")
require("conf/touchscreen")

-- Border colors live in colors.lua so the wallpaper toggle can regenerate them
-- without touching this file (hyprctl keyword is unavailable with the Lua provider).
local ok, colors = pcall(require, "colors")
if not ok then
    colors = {
        active_border   = { colors = { "rgba(6F5F40ee)", "rgba(8B764Edd)", "rgba(776644cc)", "rgba(958c77bb)" }, angle = 135 },
        inactive_border = { colors = { "rgba(958c7788)", "rgba(0E0D0D55)" }, angle = 135 },
    }
end


------------------
---- MONITORS ----
------------------

-- Explicit, deterministic layout: laptop on the left, AOC external on the right.
hl.monitor({ output = "eDP-1",    mode = "1920x1200@60",    position = "0x0",    scale = 1 })
hl.monitor({ output = "desc:AOC Q27P3C", mode = "2560x1440@59.95", position = "1920x0", scale = 1 })
-- The living-room TV shares the HDMI port but tops out at 1080p — matched by
-- description so it overrides the 1440p rule above (later match wins).
hl.monitor({ output = "desc:Philips Consumer Electronics Company PHILIPS FTV", mode = "1920x1080@60", position = "1920x0", scale = 1 })
-- Fallback for any other monitor that gets plugged in
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Plugging the TV in doesn't re-route audio on its own: EasyEffects claimed the
-- already-running streams before its blocklist applied to them, so Firefox has
-- to be pushed onto the HDMI sink again. Unplugging needs nothing -- WirePlumber
-- drops the missing target and falls back to easyeffects_sink.
hl.on("monitor.added", function()
    hl.exec_cmd("/home/trzn/.config/hypr/scripts/audio-tv.sh")
end)


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd(programs.terminal)
    -- hl.exec_cmd("nm-applet")
    hl.exec_cmd("firefox", { workspace = "2 silent" })
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("hypridle")  -- idle lock only; no lock screen right after login
    hl.exec_cmd("easyeffects --service-mode")  -- EQ (needs lsp-plugins-lv2 + calf)
    hl.exec_cmd("spotify-launcher", { workspace = "special:spotify silent" })  -- Arch spotify-launcher; plain "spotify" is not on PATH
    hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"')
    hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "xdgdesktopportal")     -- Qt apps follow the system dark preference via the desktop portal
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")         -- Electron apps (Spotify, Discord, Signal) run native Wayland


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,

        border_size = 3,

        col = colors, -- see colors.lua

        resize_on_border = true,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2,

        -- Slight transparency on unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 0.92,

        shadow = {
            enabled      = true,
            range        = 14,
            render_power = 3,
            color        = "rgba(00000040)",
        },

        blur = {
            enabled  = true,
            size     = 5,
            passes   = 2,

            vibrancy = 0.2,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Default curves
hl.curve("linear",  { type = "bezier", points = { {0, 0},     {1, 1}    } })

-- 侍 Samurai curves
hl.curve("iaido",   { type = "bezier", points = { {0.05, 0.7},  {0.1, 1}  } })  -- sudden draw — explosive start, clean stop
hl.curve("zanshin", { type = "bezier", points = { {0.22, 1.1},  {0.36, 1} } })  -- follow-through — slight overshoot, composed settle
hl.curve("noto",    { type = "bezier", points = { {0.33, 0},    {0.1, 1}  } })  -- return to stance — measured, grounded
hl.curve("kiri",    { type = "bezier", points = { {0, 0.85},    {0.15, 1} } })  -- the cut itself — near-instant, decisive

-- 斬 Animations
hl.animation({ leaf = "global",        enabled = true, speed = 10,  bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 6,   bezier = "zanshin" })
hl.animation({ leaf = "windows",       enabled = true, speed = 5,   bezier = "iaido" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3.5, bezier = "kiri",    style = "popin 80%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2.5, bezier = "noto",    style = "popin 70%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 2.5, bezier = "kiri" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 3,   bezier = "noto" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3,   bezier = "iaido" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.5, bezier = "iaido" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 2.5, bezier = "kiri",    style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 2,   bezier = "noto",    style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 2,   bezier = "kiri" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.5, bezier = "noto" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 3.5, bezier = "iaido",   style = "slidefade 30%" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 3,   bezier = "kiri",    style = "slidefade 25%" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 4.5, bezier = "noto",    style = "slidefade 60%" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 5,   bezier = "zanshin" })
-- Scratchpad (Spotify) drops down from the top edge and retreats back up,
-- instead of inheriting the horizontal slide of ordinary workspaces.
-- The direction word describes one continuous travel ("top" = enter from the top,
-- leave through the bottom), so the In/Out halves get opposite words to make it
-- come down from the top edge and retreat back up.
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 3.5, bezier = "iaido", style = "slidefadevert top 30%" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 4,   bezier = "noto",  style = "slidefadevert bottom 30%" })

-- Per-monitor workspaces: laptop (eDP-1) owns 1-5, AOC (HDMI-A-1) owns 6-10.
-- Each monitor's workspaces are independent — switching one never affects the other.
hl.workspace_rule({ workspace = "1",  monitor = "eDP-1", default = true })
hl.workspace_rule({ workspace = "2",  monitor = "eDP-1" })
hl.workspace_rule({ workspace = "3",  monitor = "eDP-1" })
hl.workspace_rule({ workspace = "4",  monitor = "eDP-1" })
hl.workspace_rule({ workspace = "5",  monitor = "eDP-1" })
hl.workspace_rule({ workspace = "6",  monitor = "HDMI-A-1", default = true })
hl.workspace_rule({ workspace = "7",  monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "8",  monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "9",  monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "10", monitor = "HDMI-A-1" })

hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },

    master = {
        new_status = "master",
    },

    cursor = {
        inactive_timeout = 5,  -- hide the pointer after 5s of no movement
    },

    gestures = {
        -- One-finger swipe from the screen edge switches workspaces (native touch;
        -- lisgd still handles the 3/4-finger gestures)
        workspace_swipe_touch = true,
        -- Touch progress is "fraction of screen width × swipe_distance" and a swipe
        -- commits at cancel_ratio × swipe_distance, so for touch only the ratio
        -- matters: 0.2 = one fifth of the screen (was half). The larger distance
        -- keeps the touchpad threshold (ratio × distance) at the old ~150 px.
        workspace_swipe_cancel_ratio = 0.2,
        workspace_swipe_distance     = 750,
    },

    misc = {
        -- hyprlock is a custom build: if it ever crashes, let a new instance take
        -- over the lock instead of leaving a dead red screen
        allow_session_lock_restore = true,

        -- awww-daemon handles wallpapers — no need for the built-in logo/background
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,

        -- Wake the screen from dpms-off on any input
        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "pl",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },

        -- Unbound touch/pen input goes to the *focused* monitor, so with the AOC
        -- plugged in a tap on the laptop panel would land on the external screen.
        touchdevice = { output = "eDP-1" },
        tablet      = { output = "eDP-1" },
    },
})


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = { 20, "monitor_h-120" },
    float = true,
})

hl.window_rule({
    name      = "spotify-special",
    match     = { class = "(?i)spotify" },
    workspace = "special:spotify silent", -- silent: don't pop the special workspace open at login
    float     = true,
    center    = true,
})

-- EasyEffects: --service-mode still spawns a window; park it out of the way
hl.window_rule({
    name      = "easyeffects-special",
    match     = { class = "^(com\\.github\\.wwmm\\.easyeffects)$" },
    workspace = "special:spotify silent",
    float     = true,
    center    = true,
})

-- Float file-picker / portal dialogs instead of tiling them
hl.window_rule({
    name  = "float-portal-dialogs",
    match = { class = "^(xdg-desktop-portal-gtk)$" },

    float  = true,
    center = true,
})

hl.window_rule({
    name  = "float-common-dialogs",
    match = { title = "^(Open File|Open Folder|Save File|Save As|File Upload|Select a File|Choose Files)(.*)$" },

    float  = true,
    center = true,
})

-- Firefox Picture-in-Picture: floating, pinned on top across workspaces
hl.window_rule({
    name  = "firefox-pip",
    match = { title = "^(Picture-in-Picture)$" },

    float             = true,
    pin               = true,
    keep_aspect_ratio = true,
    size              = { 640, 360 },
    move              = { "monitor_w-window_w-40", "monitor_h-window_h-40" },
})
