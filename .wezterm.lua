-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local act = wezterm.action
local mux = wezterm.mux

local config = {
	webgpu_power_preference = "HighPerformance",
	max_fps = 120,
	animation_fps = 1,
	inactive_pane_hsb = {
		brightness = 0.7,
		saturation = 0.7,
	},
}
-- config.front_end = "WebGpu"
config.freetype_load_flags = "NO_HINTING"
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"

-- Cursor
config.cursor_thickness = 4
config.default_cursor_style = "BlinkingBar"
config.force_reverse_video_cursor = true
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- fonts
config.font = wezterm.font({ family = "JetBrains Mono" })
config.font_rules = {
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font({ family = "Maple Mono", weight = "Bold", style = "Italic" }),
	},
	{
		italic = true,
		intensity = "Half",
		font = wezterm.font({ family = "Maple Mono", weight = "DemiBold", style = "Italic" }),
	},
	{
		italic = true,
		intensity = "Normal",
		font = wezterm.font({ family = "Maple Mono", style = "Italic" }),
	},
}
config.bold_brightens_ansi_colors = true
config.font_size = 11

-- tabs
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.show_tab_index_in_tab_bar = true
config.tab_bar_at_bottom = false
config.tab_max_width = 64
config.show_new_tab_button_in_tab_bar = false

-- window
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"

-- for transparent background
config.window_background_opacity = 1
config.window_frame = {
	border_bottom_height = 0,
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
	{
		key = ";",
		mods = "LEADER",
		action = wezterm.action_callback(function(_, pane)
			local tab = pane:tab()
			local panes = tab:panes_with_info()
			if #panes == 1 then
				pane:split({
					direction = "Right",
					size = 0.4,
				})
			elseif not panes[1].is_zoomed then
				panes[1].pane:activate()
				tab:set_zoomed(true)
			elseif panes[1].is_zoomed then
				tab:set_zoomed(false)
				panes[2].pane:activate()
			end
		end),
	},
	{ key = "i", mods = "CTRL", action = wezterm.action.EmitEvent("image_preview") },
	-- tabs
	{
		key = "f",
		mods = "LEADER",
		action = act.ShowTabNavigator,
	},
	{ key = "h", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) }, -- Previous Tab
	{ key = "l", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) }, -- Next Tab
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
-- I can use the tab navigator (LDR t), but I also want to quickly navigate tabs with index
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = act.ActivateTab(i - 1),
	})
end

-- Colorscheme
config.color_scheme = "Everforest Dark (Gogh)"

config.colors = {
	-- Default colors
	foreground = "#d3c6aa",
	background = "#000000",
	cursor_bg = "#d3c6aa",
	cursor_border = "#d3c6aa",
	cursor_fg = "#2d353b",
	-- ANSI colors
	ansi = {
		"#4b565c",
		"#e67e80",
		"#a7c080",
		"#dbbc7f",
		"#7fbbb3",
		"#d699b6",
		"#83c092",
		"#d3c6aa",
	},
	brights = {
		"#5c6a72",
		"#f85552",
		"#8da101",
		"#dfa000",
		"#3a94c5",
		"#df69ba",
		"#35a77c",
		"#dfddc8",
	},
}

if wezterm.target_triple:find("windows") then
	config.default_prog = { "nu" }
end

wezterm.on("gui-startup", function(window)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

local function get_process(tab)
	if not tab.active_pane or tab.active_pane.foreground_process_name == "" then
		return "[?]"
	end

	local process_name = string.gsub(tab.active_pane.foreground_process_name, "(.*[/\\])(.*)", "%2")
	if string.find(process_name, "lua-language-server.exe") then
		process_name = "nvim"
	end

	return process_name
end

wezterm.on("format-tab-title", function(tab, tabs, panes, conf, hover, max_width)
	local colors = wezterm.get_builtin_color_schemes()[config.color_scheme]
	wezterm.log_info("format-tab-title", colors)
	-- {
	--     "ansi": [
	--         "#4b565c",
	--         "#e67e80",
	--         "#a7c080",
	--         "#dbbc7f",
	--         "#7fbbb3",
	--         "#d699b6",
	--         "#83c092",
	--         "#d3c6aa",
	--     ],
	--     "background": "#2d353b",
	--     "brights": [
	--         "#5c6a72",
	--         "#f85552",
	--         "#8da101",
	--         "#dfa000",
	--         "#3a94c5",
	--         "#df69ba",
	--         "#35a77c",
	--         "#dfddc8",
	--     ],
	--     "cursor_bg": "#d3c6aa",
	--     "cursor_border": "#d3c6aa",
	--     "cursor_fg": "#2d353b",
	--     "foreground": "#d3c6aa",
	--     "indexed": [],
	-- }
	local background = colors.ansi[1]
	local foreground = colors.foreground
	local head_background = colors.ansi[8]

	if tab.is_active or hover then
		foreground = colors.ansi[3]
		head_background = colors.ansi[3]
	end

	local title = string.format("%s", get_process(tab))

	-- ensure that the titles fit in the available space,
	-- and that we have room for the edges.
	local max = max_width
	if #title > max then
		title = wezterm.truncate_right(title, max) .. "…"
	end

	return {
		{ Background = { Color = colors.background } },
		{ Foreground = { Color = head_background } },
		{ Text = wezterm.nerdfonts.ple_left_half_circle_thick },
		{ Background = { Color = head_background } },
		{ Foreground = { Color = colors.background } },
		{ Text = (tab.tab_index + 1) .. " " },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = " " .. title .. " " },
		{ Background = { Color = colors.background } },
		{ Foreground = { Color = background } },
		{ Text = wezterm.nerdfonts.ple_right_half_circle_thick },

		{ Background = { Color = colors.background } },
		{ Text = " " },
	}
end)

wezterm.on("update-status", function(window, pane)
	local time = wezterm.strftime("%H:%M")
	local date = wezterm.strftime("%Y-%m-%d")
	local colors = wezterm.get_builtin_color_schemes()[config.color_scheme]
	-- Right status
	window:set_right_status(wezterm.format({
		-- Wezterm has a built-in nerd fonts
		-- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html

		{ Text = " " },
		{ Background = { Color = colors.background } },
		{ Foreground = { Color = colors.brights[7] } },
		{ Text = wezterm.nerdfonts.ple_left_half_circle_thick },
		{ Background = { Color = colors.brights[7] } },
		{ Foreground = { Color = colors.background } },
		{ Text = wezterm.nerdfonts.md_calendar_clock .. " " },
		{ Background = { Color = colors.brights[1] } },
		{ Foreground = { Color = colors.foreground } },
		{ Text = " " .. date },
		{ Background = { Color = colors.background } },
		{ Foreground = { Color = colors.brights[1] } },
		{ Text = wezterm.nerdfonts.ple_right_half_circle_thick },

		{ Text = " " },
		{ Background = { Color = colors.background } },
		{ Foreground = { Color = colors.brights[2] } },
		{ Text = wezterm.nerdfonts.ple_left_half_circle_thick },
		{ Background = { Color = colors.brights[2] } },
		{ Foreground = { Color = colors.background } },
		{ Text = wezterm.nerdfonts.md_timer_sand .. " " },
		{ Background = { Color = colors.brights[1] } },
		{ Foreground = { Color = colors.foreground } },
		{ Text = " " .. time },
		{ Background = { Color = colors.background } },
		{ Foreground = { Color = colors.brights[1] } },
		{ Text = wezterm.nerdfonts.ple_right_half_circle_thick },
	}))
end)

return config
