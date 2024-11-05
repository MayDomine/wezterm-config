local w = require('wezterm')
local function is_vim(pane)
  -- 首先检查是否是 SSH 会话
  if pane:get_user_vars().IS_SSH == 'true' then
    return false
  end

  return pane:get_user_vars().IS_NVIM == 'true' or pane:get_user_vars().IS_VIM == 'true'
end

local function is_tmux(pane) 
  local env = os.getenv("TMUX")
  local flag = env ~= ""
  return flag
end

-- Mapping modifier keys to CSI codes
local mod_map = {
	SHIFT = 1,
	ALT = 2,
	CTRL = 4,
	CMD = 8,
}

-- Function: Generate CSI Sequence
local function get_csi_sequence(key, mods)
	local mod_code = 0 -- default is 0

	for mod in string.gmatch(mods, "([^|]+)") do
		if mod_map[mod] then
			mod_code = mod_code + mod_map[mod]
		end
	end

	local csi_sequence = string.format("\x1b[%d;%du", string.byte(key), mod_code + 1)
	return csi_sequence
end
local direction_keys = {
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}

local function wezterm_nvim(operation, key, mods)
	return {
		key = key,
		mods = mods,
		action = w.action_callback(function(win, pane)
			-- not run tmux
			if is_vim(pane) or is_tmux(pane) then
				-- pass the keys through to vim/nvim
				local csi_keymap = get_csi_sequence(key, mods)
				win:perform_action({ SendString = csi_keymap }, pane)
				-- win:perform_action({ SendKey = { key = key, mods = mods } }, pane)
			else
				if operation == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				elseif operation == "move" then
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				elseif operation == "split" then
					win:perform_action({ SplitPane = { direction = direction_keys[key] } }, pane)
				elseif operation == "close_tab" then
					win:perform_action({ CloseCurrentPane = { confirm = false } }, pane)
				end
				-- end
			end
		end),
	}
end

return {
  keys = {
    wezterm_nvim('move', 'h', 'ALT'),
    wezterm_nvim('move', 'j', 'ALT'),
    wezterm_nvim('move', 'k', 'ALT'),
    wezterm_nvim('move', 'l', 'ALT'),
    -- resize panes
    wezterm_nvim('resize', 'h', 'ALT|SHIFT'),
    wezterm_nvim('resize', 'j', 'ALT|SHIFT'),
    wezterm_nvim('resize', 'k', 'ALT|SHIFT'),
    wezterm_nvim('resize', 'l', 'ALT|SHIFT'),
  }
}
