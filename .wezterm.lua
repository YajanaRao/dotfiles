-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config = {
	font = wezterm.font("JetBrains Mono"),
	enable_tab_bar = true,
	use_fancy_tab_bar = false,
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
	keys = {
		-- splitting
		{
			mods = "LEADER",
			key = "-",
			action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{
			mods = "LEADER",
			key = "=",
			action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			mods = "LEADER",
			key = "m",
			action = wezterm.action.TogglePaneZoomState,
		},
		-- rotate panes
		{
			mods = "LEADER",
			key = "Space",
			action = wezterm.action.RotatePanes("Clockwise"),
		},
		-- show the pane selection mode, but have it swap the active and selected panes
		{
			mods = "LEADER",
			key = "0",
			action = wezterm.action.PaneSelect({
				mode = "SwapWithActive",
			}),
		},
	},
	-- tab_bar_at_bottom = true,
	tab_max_width = 30,
	color_scheme = "Tokyo Night",
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",

	-- for transparent background
	window_background_opacity = 0.9,
	window_frame = {
		border_left_width = "0.0cell",
		border_right_width = "0.0cell",
		border_bottom_height = "0.10cell",
		border_top_height = "0.0cell",
	},
	window_padding = {
		left = 3,
		right = 3,
		top = 5,
		bottom = "0.0cell",
	},
	inactive_pane_hsb = {
		saturation = 1.0,
		brightness = 1.0,
	},
	default_prog = { "powershell.exe" },
	ssh_domains = {
		{
			-- This name identifies the domain
			name = "sergio",
			-- The hostname or address to connect to. Will be used to match settings
			-- from your ssh config file
			remote_address = "10.0.216.162",
			-- The username to use on the remote host
			username = "ubuntu",
		},
	},
}

return config
