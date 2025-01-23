local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.color_scheme = 'Catppuccin Mocha'
config.default_prog = {'powershell.exe', '-NoLogo'}

config.window_decorations = "RESIZE"

config.enable_tab_bar = false
config.show_tabs_in_tab_bar = false
config.show_new_tab_button_in_tab_bar = false

config.color_scheme = 'AdventureTime'
config.font = wezterm.font('JetBrainsMono Nerd Font')
config.font_size = 13
config.line_height = 1
config.default_cursor_style = "SteadyUnderline"

return config
