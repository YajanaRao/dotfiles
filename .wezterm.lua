-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local act = wezterm.action
local mux = wezterm.mux

local config = {
	webgpu_power_preference = "HighPerformance",

	inactive_pane_hsb = {
		brightness = 0.5,
		saturation = 0.5,
	},
}

-- Cursor
config.cursor_thickness = 4
config.default_cursor_style = "BlinkingBar"
config.force_reverse_video_cursor = true
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- fonts
config.font = wezterm.font("JetBrains Mono")
-- config.font_size = 11
-- config.line_height = 1.35

-- tabs
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.show_tab_index_in_tab_bar = true
config.tab_bar_at_bottom = false
config.tab_max_width = 64

-- window
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"

-- for transparent background
config.window_background_opacity = 0.98

config.window_frame = {
	border_bottom_height = "0.5cell",
}
config.window_padding = {
	left = 0,
	right = 0,
	top = "0.2cell",
	bottom = 0,
}

-- Keymaps
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	-- tabs
	{
		key = "f",
		mods = "LEADER",
		action = act.ShowTabNavigator,
	},
	{
		key = "i",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Prev"),
	},
	{
		key = "o",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Next"),
	},
	-- splitting
	{
		mods = "LEADER",
		key = "v",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "s",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "m",
		action = act.TogglePaneZoomState,
	},
	-- rotate panes
	{
		mods = "LEADER",
		key = "Space",
		action = act.RotatePanes("Clockwise"),
	},
	-- show the pane selection mode, but have it swap the active and selected panes
	{
		mods = "LEADER",
		key = "0",
		action = act.PaneSelect({
			mode = "SwapWithActive",
		}),
	},
	-- Switch between workspaces
	{
		mods = "LEADER",
		key = "w",
		action = act.ShowLauncherArgs({
			flags = "FUZZY|WORKSPACES",
		}),
	},
	{ key = "n", mods = "LEADER", action = act.SwitchWorkspaceRelative(1) },
	--Rename Workspace
	{
		mods = "LEADER",
		key = "R",
		action = act.PromptInputLine({
			description = "Enter new name for workspace",
			action = wezterm.action_callback(function(_, _, line)
				if line then
					wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
				end
			end),
		}),
	},
	{ key = "p", mods = "LEADER", action = wezterm.action.SwitchWorkspaceRelative(-1) },
}

-- Colorscheme
-- FIXME works on windows. Make it work for MacOS and Linux
config.color_scheme_dirs = { wezterm.home_dir .. "/AppData/Local/nvim-data/tokyonight/extras/wezterm" }
config.color_scheme = "tokyonight_night"
wezterm.add_to_config_reload_watch_list(config.color_scheme_dirs[1] .. config.color_scheme .. ".toml")

config.colors = {
	indexed = { [241] = "#65bcff" },
}

if wezterm.target_triple:find("windows") then
	config.default_prog = { "pwsh" }
end

wezterm.on("gui-startup", function(window)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
	local colors = conf.resolved_palette

	local background = colors.tab_bar.inactive_tab.bg_color
	local foreground = colors.tab_bar.inactive_tab.fg_color
	local edge_background = colors.tab_bar.background

	if tab.is_active or hover then
		background = colors.tab_bar.active_tab.bg_color
		foreground = colors.tab_bar.active_tab.fg_color
	end

	local edge_foreground = background

	local title = tab_title(tab)

	-- ensure that the titles fit in the available space,
	-- and that we have room for the edges.
	local max = max_width - 8
	if #title > max then
		title = wezterm.truncate_right(title, max) .. "…"
	end

	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = "" },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Attribute = { Intensity = tab.is_active and "Bold" or "Normal" } },
		{ Text = " " .. (tab.tab_index + 1) .. ": " .. title .. " " },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = " " },
	}
end)

wezterm.on("update-status", function(window, pane)
	local time = wezterm.strftime("%Y-%m-%d %H:%M")
	local colors = config.resolved_palette

	-- Right status
	window:set_right_status(wezterm.format({
		-- Wezterm has a built-in nerd fonts
		-- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html

		{ Text = " " },
		{ Background = { Color = colors.background } },
		{ Foreground = { Color = colors.ansi[8] } },
		{ Text = wezterm.nerdfonts.ple_left_half_circle_thick },
		{ Background = { Color = colors.ansi[8] } },
		{ Foreground = { Color = colors.background } },
		{ Text = wezterm.nerdfonts.md_calendar_clock .. " " },
		{ Background = { Color = colors.ansi[1] } },
		{ Foreground = { Color = colors.foreground } },
		{ Text = " " .. time },
		{ Background = { Color = colors.background } },
		{ Foreground = { Color = colors.ansi[1] } },
		{ Text = wezterm.nerdfonts.ple_right_half_circle_thick },
	}))
end)

return config
