local terminal  = "foot"
local menu      = "rofi -show drun"

local mainMod   = "SUPER"
local secondMod = "SUPER + SHIFT"
local thirdMod  = "SUPER + SHIFT + CTRL"
local left      = "H"
local right     = "L"
local up        = "K"
local down      = "J"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(thirdMod .. " + E",
  hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist-rofi-img"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(secondMod .. " + W", hl.dsp.exec_cmd("cycle-wallpaper"))
-- hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only
-- Move focus
hl.bind(secondMod .. " + backslash", hl.dsp.exec_cmd("hyprctl dispatch focuswindow floating/tiled"))

hl.bind(mainMod .. " + " .. left, hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + " .. right, hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + " .. up, hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + " .. down, hl.dsp.focus({ direction = "down" }))
-- Swap windows
hl.bind(secondMod .. " + " .. left, hl.dsp.window.swap({ direction = "left" }))
hl.bind(secondMod .. " + " .. right, hl.dsp.window.swap({ direction = "right" }))
hl.bind(secondMod .. " + " .. up, hl.dsp.window.swap({ direction = "up" }))
hl.bind(secondMod .. " + " .. down, hl.dsp.window.swap({ direction = "down" }))
-- Move window
hl.bind(secondMod .. " + " .. left, hl.dsp.window.move({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(secondMod .. " + " .. right, hl.dsp.window.move({ x = 20, y = 0, relative = true }), { repeating = true })
hl.bind(secondMod .. " + " .. up, hl.dsp.window.move({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(secondMod .. " + " .. down, hl.dsp.window.move({ x = 0, y = 20, relative = true }), { repeating = true })


-- Resize submap
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
  hl.bind(right, hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
  hl.bind(left, hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
  hl.bind(up, hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
  hl.bind(down, hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })

  hl.bind("SHIFT + " .. right, hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
  hl.bind("SHIFT + " .. left, hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
  hl.bind("SHIFT + " .. up, hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
  hl.bind("SHIFT + " .. down, hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })

  hl.bind(mainMod .. " + period", hl.dsp.layout("move +col"))
  hl.bind(mainMod .. " + comma", hl.dsp.layout("swapcol l"))

  hl.bind(mainMod .. " + R", hl.dsp.submap("reset"))
  hl.bind("Return", hl.dsp.submap("reset"))
  hl.bind("Escape", hl.dsp.submap("reset"))
end)

hl.bind(mainMod .. " + backslash", hl.dsp.window.float())
hl.bind(mainMod .. " + A", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(secondMod .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end

local layouts = {
  "dwindle",
  "scrolling",
  "master",
}

local function indexOf(tbl, target)
  for i, v in ipairs(tbl) do
    if v == target then
      return i
    end
  end
  return nil
end


hl.bind(mainMod .. "+ N", function()
  local currentLayout = hl.get_active_workspace().tiled_layout
  local index = indexOf(layouts, currentLayout)
  if (index == #layouts) then
    index = 0
  end
  local next = index + 1
  hl.dsp.workspace.rename({ workspace = hl.get_active_workspace().name, name = layouts[next] })
end)

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(secondMod .. " + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volume-up"), { locked = true, repeating = true })
hl.bind("SHIFT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("volume-up extreme"), { locked = true, repeating = true })
hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("volume-up precise"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volume-down"), { locked = true, repeating = true })
hl.bind("SHIFT + XF86AudioLowerVolume", hl.dsp.exec_cmd("volume-down extreme"), { locked = true, repeating = true })
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("volume-down precise"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 10%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("next-song"), { locked = true })
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("next-song"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("toggle-play"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("toggle-play"), { locked = true })
hl.bind(mainMod .. "+ P", hl.dsp.exec_cmd("toggle-play"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("prev-song"), { locked = true })
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("prev-song"), { locked = true })
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("play-next"), { locked = true })
hl.bind(secondMod .. " + M", hl.dsp.exec_cmd("select-play-next"), { locked = true })
hl.bind(secondMod .. " + N", hl.dsp.exec_cmd("networkmanager_dmenu"), { locked = true })
hl.bind("Print", hl.dsp.exec_cmd("grim"), { locked = true })
hl.bind("SHIFT + Print", hl.dsp.exec_cmd('grim -g "$(slurp)"'), { locked = true })
