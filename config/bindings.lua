local wezterm = require('wezterm')
local platform = require('utils.platform')()
local backdrops = require('utils.backdrops')
local ssh = require('plugins.ssh_menu')
local scrollback = require('plugins.scrollback')
local workspace = require('config.workspace')
local act = wezterm.action
local mod = {}

local dump_scrollback_to_file = function(window, pane)
    -- Retrieve the current viewport's text.
    -- Pass an optional number of lines (eg: 2000) to retrieve
    -- that number of lines starting from the bottom of the viewport
    local scrollback = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows);
    -- Create a temporary file to pass to vim
    local name = os.tmpname();
    local f = io.open(name, "w+");
    f:write(scrollback);
    f:flush();
    f:close();
    return name
end


wezterm.on("trigger-vim-with-scrollback", function(window, pane)
  local filename = dump_scrollback_to_file(window, pane)
  -- Open a new window running fzf to fuzzy search scrollback
  print("dumping scrollback to file")
  window:perform_action(wezterm.action{SpawnCommandInNewWindow={
    args={"zsh", "-c", "nvim < " .. filename},
    domain = 'DefaultDomain',
  },
  }, pane)
end)

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
  {
    key = 'f',
    mods = mod.SUPER_ALL,
    action = wezterm.action.ToggleFullScreen,
  },
  {
    key = 'k',
    mods = "LEADER",
    action = act.ClearScrollback 'ScrollbackAndViewport',

  },

  --
    {
    key="o", mods=mod.SUPER_SHIFT,
      action=wezterm.action{EmitEvent="trigger-vim-with-scrollback"}},
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
  {
    key = 'r',
    mods = mod.SUPER_SHIFT,
    action = act.PromptInputLine {
      description = 'Enter new name for workspace',
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          -- window:active_tab():set_title(line)
          -- tab
        wezterm.mux.rename_workspace(
          wezterm.mux.get_active_workspace(),
          line
        )
        end
      end),
    },
   },
   { key = 'e', mods = mod.SUPER, action = act.ShowLauncherArgs({ flags = 'FUZZY|TABS' }) },
   {
      key = 'n',
      mods = mod.SUPER_SHIFT,
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
   { key = 't',          mods = mod.SUPER,     action = act.SpawnTab('CurrentPaneDomain') },
   { key = 't',          mods = mod.SUPER_REV, action = act.SpawnTab({ DomainName = 'WSL:Ubuntu' }) },
   { key = 's',          mods = "LEADER", action =  wezterm.action_callback(function(window, pane)
    ssh.ssh_menu(window, pane, { use_ssh_conf = true , connect_to_host= false, split_in_window = true})
  end)},
   { key = 'S',          mods = "LEADER", action =  wezterm.action_callback(function(window, pane)
    ssh.ssh_menu(window, pane, { use_ssh_conf = true , connect_to_host= false, split_in_window = false})
  end)},
   { key = 'c',          mods = "LEADER", action =  wezterm.action_callback(function(window, pane)
    ssh.ssh_menu(window, pane, { use_ssh_conf = true , connect_to_host= true})
  end)},
   { key = 't',          mods = "LEADER", action =  wezterm.action_callback(function(window, pane)
    ssh.ssh_menu(window, pane, { use_ssh_conf = true , connect_to_host= false, use_mux = true})
  end)},
   { key = 'h',          mods = "LEADER", action =  act.SplitHorizontal({args = {"htop"} })},
   { key = 'w',          mods = mod.SUPER, action = act.CloseCurrentTab({ confirm = true }) },

   -- tabs: navigation
   { key = '1',          mods = mod.SUPER,     action = act.ActivateTab(0) },
   { key = '2',          mods = mod.SUPER,     action = act.ActivateTab(1) },
   { key = '3',          mods = mod.SUPER,     action = act.ActivateTab(2) },
   { key = '4',          mods = mod.SUPER,     action = act.ActivateTab(3) },
   { key = '5',          mods = mod.SUPER,     action = act.ActivateTab(4) },
   { key = '6',          mods = mod.SUPER,     action = act.ActivateTab(5) },
   { key = '7',          mods = mod.SUPER,     action = act.ActivateTab(6) },
   { key = '8',          mods = mod.SUPER,     action = act.ActivateTab(7) },
   { key = '9',          mods = mod.SUPER,     action = act.ActivateTab(8) },
   { key = '0',          mods = mod.SUPER,     action = act.ActivateTab(9) },
   { key = ',',          mods = mod.SUPER,     action = act.ActivateTabRelative(-1) },
   { key = '.',          mods = mod.SUPER,     action = act.ActivateTabRelative(1) },
   { key = ',',          mods = mod.SUPER_SHIFT, action = act.MoveTabRelative(-1) },
   { key = '.',          mods = mod.SUPER_SHIFT, action = act.MoveTabRelative(1) },

   -- window --
   -- spawn windows
   { key = '-',          mods = mod.SUPER_SHIFT,     action = act.SpawnWindow },
   { key = 'j', mods = mod.SUPER, action = act.SwitchWorkspaceRelative(1) },
   { key = 'k', mods = mod.SUPER, action = act.SwitchWorkspaceRelative(-1) },

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
            -- backdrops:set_img(window, tonumber(idx))
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
    { key = 'n', mods = mod.SUPER, action =  wezterm.action_callback(function(window, pane)
      ssh.ssh_menu(window, pane, { use_ssh_conf = true , connect_to_host= false, use_mux = true})
    end)},
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
    key = '-',
      mods = mod.SUPER,
      action = act.ActivateKeyTable({
         name = 'workspace_mode',
         one_shot = false,
         timemout_miliseconds = 1000,
    }),
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
      { key = 'p', mods = mod.SUPER, action = act.CopyMode 'Close' },
      { key = 'f', mods = mod.SUPER, action = act.CopyMode 'Close' },
    },
  workspace_mode = {
      { key = 'j', action = act.SwitchWorkspaceRelative(1) },
      { key = 'k', action = act.SwitchWorkspaceRelative(-1) },
      { key = 'n', action =  wezterm.action_callback(function(window, pane)
        ssh.ssh_menu(window, pane, { use_ssh_conf = true , connect_to_host= false, use_mux = true})
      end)},

      { key = 'w', action = wezterm.action_callback(function(window, pane, line)
        local domain_name = pane:get_domain_name(pane)
        window:perform_action(
        act.Multiple{
          "PopKeyTable",
          act.DetachDomain {DomainName = domain_name}
        } ,pane)
      end)
      },
      {
        key = 'd', action = wezterm.action_callback(function(window, pane)
        local w = window:active_workspace()
        workspace.kill_workspace(w, window, pane)
      end)
      },
      { key = 'q', action = 'PopKeyTable' },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'Enter', action = 'PopKeyTable' },
  },
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
