-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local act = wezterm.action

local icons = {
	["C:\\WINDOWS\\system32\\cmd.exe"] = wezterm.nerdfonts.md_console_line,
	["bash"] = wezterm.nerdfonts.cod_terminal_bash,
	["curl"] = wezterm.nerdfonts.mdi_flattr,
	["gh"] = wezterm.nerdfonts.dev_github_badge,
	["git"] = wezterm.nerdfonts.md_git,
	["htop"] = wezterm.nerdfonts.md_chart_areaspline,
	["btop"] = wezterm.nerdfonts.md_chart_areaspline,
	["lua"] = wezterm.nerdfonts.seti_lua,
	["node"] = wezterm.nerdfonts.dev_nodejs,
	["npm"] = wezterm.nerdfonts.dev_npm,
	["nvim-qt"] = wezterm.nerdfonts.custom_vim,
	["nvim"] = wezterm.nerdfonts.custom_neovim,
	["pacman"] = "󰮯 ",
	["paru"] = "󰮯 ",
	["pwsh.exe"] = wezterm.nerdfonts.md_console,
	["sudo"] = wezterm.nerdfonts.fa_hashtag,
	["vim"] = wezterm.nerdfonts.dev_vim,
	["wget"] = wezterm.nerdfonts.mdi_arrow_down_box,
	["zsh"] = wezterm.nerdfonts.dev_terminal,
	["lazygit"] = wezterm.nerdfonts.cod_github,
	["esbuild.exe"] = wezterm.nerdfonts.md_webpack,
}

local arrow_solid = ""
local arrow_thin = ""

local config = {
	font = wezterm.font("JetBrains Mono"),
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,
	use_fancy_tab_bar = false,
	leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
	keys = {
		-- tabs
		{
			key = "f",
			mods = "LEADER",
			action = wezterm.action.ShowTabNavigator,
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
			action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{
			mods = "LEADER",
			key = "s",
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
		-- Switch between workspaces
		{
			mods = "LEADER",
			key = "w",
			action = wezterm.action.ShowLauncherArgs({
				flags = "FUZZY|WORKSPACES",
			}),
		},
		{ key = "n", mods = "LEADER", action = wezterm.action.SwitchWorkspaceRelative(1) },
		--Rename Workspace
		{
			mods = "LEADER",
			key = "R",
			action = wezterm.action.PromptInputLine({
				description = "Enter new name for workspace",
				action = wezterm.action_callback(function(_, _, line)
					if line then
						wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
					end
				end),
			}),
		},
		{ key = "p", mods = "LEADER", action = wezterm.action.SwitchWorkspaceRelative(-1) },
	},
	tab_bar_at_bottom = false,
	tab_max_width = 30,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",
	cursor_thickness = 4,

	webgpu_power_preference = "HighPerformance",
	cursor_blink_ease_in = "Constant",
	cursor_blink_ease_out = "Constant",
	-- for transparent background
	window_background_opacity = 0.98,
	window_frame = {
		border_left_width = "0.0cell",
		border_right_width = "0.0cell",
		border_bottom_height = "0.10cell",
		border_top_height = "0.0cell",
	},
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	inactive_pane_hsb = {
		saturation = 1.0,
		brightness = 1.0,
	},
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

function title(tab, max_width)
	local title = (tab.tab_title and #tab.tab_title > 0) and tab.tab_title or tab.active_pane.title
	local process, other = title:match("^(%S+)%s*%-?%s*%s*(.*)$")
	if icons[process] then
		title = icons[process] .. " " .. (other or "")
	end

	local is_zoomed = false
	for _, pane in ipairs(tab.panes) do
		if pane.is_zoomed then
			is_zoomed = true
			break
		end
	end
	if is_zoomed then -- or (#tab.panes > 1 and not tab.is_active) then
		title = " " .. title
	end

	title = wezterm.truncate_right(title, max_width - 3)
	return " " .. title .. " "
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = title(tab, max_width)
	local colors = config.resolved_palette
	local active_bg = colors.tab_bar.active_tab.bg_color
	local inactive_bg = colors.tab_bar.inactive_tab.bg_color

	local tab_idx = 1
	for i, t in ipairs(tabs) do
		if t.tab_id == tab.tab_id then
			tab_idx = i
			break
		end
	end
	local is_last = tab_idx == #tabs
	local next_tab = tabs[tab_idx + 1]
	local next_is_active = next_tab and next_tab.is_active
	local arrow = (tab.is_active or is_last or next_is_active) and arrow_solid or arrow_thin
	local arrow_bg = inactive_bg
	local arrow_fg = colors.tab_bar.inactive_tab_edge

	if is_last then
		arrow_fg = tab.is_active and active_bg or inactive_bg
		arrow_bg = colors.tab_bar.background
	elseif tab.is_active then
		arrow_bg = inactive_bg
		arrow_fg = active_bg
	elseif next_is_active then
		arrow_bg = active_bg
		arrow_fg = inactive_bg
	end

	local ret = tab.is_active
			and {
				{ Attribute = { Intensity = "Bold" } },
				{ Attribute = { Italic = true } },
			}
		or {}
	ret[#ret + 1] = { Text = title }
	ret[#ret + 1] = { Foreground = { Color = arrow_fg } }
	ret[#ret + 1] = { Background = { Color = arrow_bg } }
	ret[#ret + 1] = { Text = arrow }
	return ret
end)

return config
