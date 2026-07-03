hl.window_rule({
  name  = "move-hyprland-run",
  match = { class = "hyprland-run" },

  move  = "20 monitor_h-120",
  float = true,
})

hl.window_rule({
  -- Fix some dragging issues with XWayland
  name     = "fix-xwayland-drags",
  match    = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },

  no_focus = true,
})

hl.window_rule({
  -- Ignore maximize requests from all apps. You'll probably like this.
  name           = "suppress-maximize-events",
  match          = { class = ".*" },

  suppress_event = "maximize",
})

hl.window_rule({
  name = "zen",
  match = {
    class = "zen"
  },
  workspace = 1
})

hl.window_rule({
  name = "code",
  match = {
    class = "code"
  },
  workspace = 2
})

hl.window_rule({
  name = "zed",
  match = {
    class = "dev.zed.Zed"
  },
  workspace = 2
})

hl.window_rule({
  name = "helium",
  match = {
    class = "helium"
  },
  workspace = 3
})

hl.window_rule({
  match        = { class = "nz.co.mega.megasync" },
  stay_focused = true,
  float        = true,
  move         = { "monitor_w - 358", 119 },
  size         = { 300, 400 },
  pin          = true
})

hl.layer_rule({
  match = { namespace = "rofi" },
  blur = true,
  ignore_alpha = 0,
})

hl.workspace_rule({ workspace = "name:dwindle", layout = "dwindle" })
hl.workspace_rule({ workspace = "name:scrolling", layout = "scrolling" })
hl.workspace_rule({ workspace = "name:master", layout = "master" })
