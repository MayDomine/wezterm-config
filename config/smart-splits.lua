local w = require('wezterm')

-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
  -- 首先检查是否是 SSH 会话
  if pane:get_user_vars().IS_SSH == 'true' then
    return false
  end

  return pane:get_user_vars().IS_NVIM == 'true' or pane:get_user_vars().IS_VIM == 'true'
end

-- if you *ARE* lazy-loading smart-splits.nvim (not recommended)
-- you have to use this instead, but note that this will not work
-- in all cases (e.g. over an SSH connection). Also note that
-- `pane:get_foreground_process_name()` can have high and highly variable
-- latency, so the other implementation of `is_vim()` will be more
-- performant as well.

local direction_keys = {
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}
local resize_mods = 'ALT|SHIFT'
local move_mods = 'ALT'
local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == 'resize' and resize_mods or move_mods,
    action = w.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = key, mods = resize_or_move == 'resize' and resize_mods or move_mods },
        }, pane)
      else
        if resize_or_move == 'resize' then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
        end
      end
    end),
  }
end

return {
  keys = {
    -- move between split panes
    split_nav('move', 'h'),
    split_nav('move', 'j'),
    split_nav('move', 'k'),
    split_nav('move', 'l'),
    -- resize panes
    split_nav('resize', 'h'),
    split_nav('resize', 'j'),
    split_nav('resize', 'k'),
    split_nav('resize', 'l'),
  },
}
