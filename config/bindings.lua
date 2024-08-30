local wezterm = require('wezterm')
local platform = require('utils.platform')()
local backdrops = require('utils.backdrops')
local act = wezterm.action

local mod = {}

if platform.is_mac then
   mod.SUPER = 'SUPER'
   mod.SUPER_REV = 'SUPER|ALT'
   mod.SUPER_ALL = 'CTRL|ALT|SHIFT|SUPER'
   mod.SUPER_SHIFT = 'SUPER|SHIFT'
elseif platform.is_win or platform.is_linux then
   mod.SUPER = 'ALT' -- to not conflict with Windows key shortcuts
   mod.SUPER_REV = 'ALT|CTRL'
end

-- stylua: ignore
local keys = {
   -- misc/useful --
   { key = 'p', mods = mod.SUPER, action = 'ActivateCopyMode' },
   { key = 'p', mods = mod.SUPER_SHIFT, action = act.ActivateCommandPalette },
   { key = 'e', mods = mod.SUPER_SHIFT, action = act.ShowLauncher },
   {
    key = 'r',
    mods = mod.SUPER,
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
   },
   { key = 'e', mods = mod.SUPER, action = act.ShowLauncherArgs({ flags = 'FUZZY|TABS' }) },
   {
      key = 'g',
      mods = mod.SUPER,
      action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }),
   },
   { key = 'F11', mods = 'NONE',    action = act.ToggleFullScreen },
   { key = 'F12', mods = 'NONE',    action = act.ShowDebugOverlay },
   { key = 'f',   mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = '' }) },
   {
      key = 'u',
      mods = mod.SUPER,
      action = wezterm.action.QuickSelectArgs({
         label = 'open url',
         patterns = {
            '\\((https?://\\S+)\\)',
            '\\[(https?://\\S+)\\]',
            '\\{(https?://\\S+)\\}',
            '<(https?://\\S+)>',
            '\\bhttps?://\\S+[)/a-zA-Z0-9-]+'
         },
         action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            wezterm.log_info('opening: ' .. url)
            wezterm.open_with(url)
         end),
      }),
   },

   -- cursor movement --
   { key = 'h',  mods = mod.SUPER_SHIFT,     action = act.SendString '\x1bOH' },
   { key = 'l',  mods = mod.SUPER_SHIFT,     action = act.SendString '\x1bOF' },
   { key = 'Backspace',  mods = mod.SUPER,     action = act.SendString '\x17' },
   { key = 'Backspace',  mods = mod.SUPER_SHIFT,     action = act.SendString '\x15' },

   -- copy/paste --
   { key = 'c',          mods = mod.SUPER,  action = act.CopyTo('Clipboard') },
   { key = 'v',          mods = mod.SUPER,  action = act.PasteFrom('Clipboard') },

   -- tabs --
   -- tabs: spawn+close
   { key = 't',          mods = mod.SUPER,     action = act.SpawnTab('DefaultDomain') },
   { key = 't',          mods = mod.SUPER_REV, action = act.SpawnTab({ DomainName = 'WSL:Ubuntu' }) },
   { key = 'w',          mods = mod.SUPER_ALL, action = act.CloseCurrentTab({ confirm = false }) },

   -- tabs: navigation
   { key = '1',          mods = mod.SUPER,     action = act.ActivateTab(0) },
   { key = '2',          mods = mod.SUPER,     action = act.ActivateTab(1) },
   { key = '3',          mods = mod.SUPER,     action = act.ActivateTab(2) },
   { key = '4',          mods = mod.SUPER,     action = act.ActivateTab(3) },
   { key = '5',          mods = mod.SUPER,     action = act.ActivateTab(4) },
   { key = '6',          mods = mod.SUPER,     action = act.ActivateTab(5) },
   { key = ',',          mods = mod.SUPER,     action = act.ActivateTabRelative(-1) },
   { key = '.',          mods = mod.SUPER,     action = act.ActivateTabRelative(1) },
   { key = ',',          mods = mod.SUPER_SHIFT, action = act.MoveTabRelative(-1) },
   { key = '.',          mods = mod.SUPER_SHIFT, action = act.MoveTabRelative(1) },

   -- window --
   -- spawn windows
   { key = 'n',          mods = mod.SUPER,     action = act.SpawnWindow },

   -- background controls --
   {
      key = [[/]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:random(window)
      end),
   },
   {
      key = [[,]],
      mods = mod.SUPER_REV,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:cycle_back(window)
      end),
   },
   {
      key = [[.]],
      mods = mod.SUPER_REV,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:cycle_forward(window)
      end),
   },
   {
      key = [[/]],
      mods = mod.SUPER_REV,
      action = act.InputSelector({
         title = 'Select Background',
         choices = backdrops:choices(),
         fuzzy = true,
         fuzzy_description = 'Select Background: ',
         action = wezterm.action_callback(function(window, _pane, idx)
            ---@diagnostic disable-next-line: param-type-mismatch
            backdrops:set_img(window, tonumber(idx))
         end),
      }),
   },

   -- panes --
   -- panes: split panes
   {
      key = 'd',
      mods = mod.SUPER,
      action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
   },
   {
      key = 'd',
      mods = mod.SUPER_SHIFT,
      action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
   },

   -- panes: zoom+close pane
   { key = 'Enter', mods = mod.SUPER,     action = act.TogglePaneZoomState },
   { key = 'w',     mods = mod.SUPER,     action = act.CloseCurrentPane({ confirm = false }) },

   -- panes: navigation
   { key = 'k',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Up') },
   { key = 'j',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Down') },
   { key = 'h',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Left') },
   { key = 'l',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Right') },
   {
      key = 'p',
      mods = mod.SUPER_REV,
      action = act.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' }),
   },

   -- key-tables --
   -- resizes fonts
   {
      key = 'f',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_font',
         one_shot = false,
         timemout_miliseconds = 1000,
      }),
   },

   {
      key = 'q',
      mods = 'LEADER',
      action = act.SplitHorizontal({ args = { 'ssh' , 'qiyuan', "-t", "/home/hanxv/.local/share/bin/zellij a sa"}}),
   },

   {
      key = 'c',
      mods = 'LEADER',
      action = act.SplitHorizontal({ args = { 'ssh' , 'cent'}}),
   },
   -- resize panes
   {
      key = 'p',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_pane',
         one_shot = false,
         timemout_miliseconds = 1000,
      }),
   },
}

-- stylua: ignore
local key_tables = {
   resize_font = {
      { key = 'k',      action = act.IncreaseFontSize },
      { key = 'j',      action = act.DecreaseFontSize },
      { key = 'r',      action = act.ResetFontSize },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
   resize_pane = {
      { key = 'k',      action = act.AdjustPaneSize({ 'Up', 1 }) },
      { key = 'j',      action = act.AdjustPaneSize({ 'Down', 1 }) },
      { key = 'h',      action = act.AdjustPaneSize({ 'Left', 1 }) },
      { key = 'l',      action = act.AdjustPaneSize({ 'Right', 1 }) },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
  search_mode = {
      { key = 'n', mods = mod.SUPER, action = act.CopyMode 'NextMatch' },
      { key = 'n', mods = mod.SUPER_SHIFT, action = act.CopyMode 'PriorMatch' },
      { key = 'Escape', mods = "NONE", action = act.CopyMode 'Close' },
    }
  }

local mouse_bindings = {
   -- Ctrl-click will open the link under the mouse cursor
   {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
   },
}
local smart_split_keybindings = require('config.smart-splits').keys
for k, v in pairs(smart_split_keybindings) do
   table.insert(keys, 1, v)
end
return {
   disable_default_key_bindings = true,
   leader = { key = 'o', mods = mod.SUPER },
   keys = keys,
   key_tables = key_tables,
   mouse_bindings = mouse_bindings,
}
