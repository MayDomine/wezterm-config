local wezterm = require('wezterm')
local act = wezterm.action
local M = {}


local dump_scrollback_to_file = function(window, pane)
    -- Retrieve the current viewport's text.
    -- Pass an optional number of lines (eg: 2000) to retrieve
    -- that number of lines starting from the bottom of the viewport
    local scrollback = pane:get_lines_as_text();

    -- Create a temporary file to pass to vim
    local name = os.tmpname();
    local f = io.open(name, "w+");
    f:write(scrollback);
    f:flush();
    f:close();
    return name
end

wezterm.on("trigger-skim-with-scrollback", function(window, pane)
  local filename = dump_scrollback_to_file(window, pane)
  -- Open a new window running fzf to fuzzy search scrollback
  window:perform_action(wezterm.action{SpawnCommandInNewWindow={
    args={"fish", "-c", "fzf < " .. filename}}
  }, pane)
end)

M.scrollback = function ()
    wezterm.action{EmitEvent="trigger-vim-with-scrollback"}
end

return M
