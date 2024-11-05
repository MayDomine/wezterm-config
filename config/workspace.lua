local wezterm = require("wezterm")
local M = {}

M.filter = function(tbl, callback)
	local filt_table = {}

	for i, v in ipairs(tbl) do
		if callback(v, i) then
			table.insert(filt_table, v)
		end
	end
	return filt_table
end

local function _kill_helper(workspace)
	local success, stdout =
		wezterm.run_child_process({ "/opt/homebrew/bin/wezterm", "cli", "list", "--format=json" })

	if success then
		local json = wezterm.json_parse(stdout)
		if not json then
			return
		end

		local workspace_panes = M.filter(json, function(p)
			return p.workspace == workspace
		end)

		for _, p in ipairs(workspace_panes) do
			wezterm.run_child_process({
				"/opt/homebrew/bin/wezterm",
				"cli",
				"kill-pane",
				"--pane-id=" .. p.pane_id,
			})
		end
	end
end

M.kill_workspace = function(workspace, window, pane)
  wezterm.log_info('Killing workspace: ', workspace)
  window:perform_action(wezterm.action.PromptInputLine({
    description = 'Are you sure you want to kill the workspace?(y/n)',
    action = wezterm.action_callback(function(w, pane, line)
        -- line will be `nil` if they hit escape without entering anything
       wezterm.log_info('line: ', line)
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line == 'y' then
        window:perform_action(
          _kill_helper(workspace)
        )
        else
          return
        end
      end)
  }), pane)
 -- confirm prompt
  
-- local confirm = wezterm.gui.default_gui_startup_args()
--     confirm.args = {
--         "gui",
--         "prompt",
--         "--prompt-text=Are you sure you want to kill the workspace '" .. workspace .. "'? (y/n)",
--         "--no-wrap",
--     }
--
--     local success, stdout = wezterm.run_child_process(confirm)
--
--     if success then
--         local response = stdout:match("^%s*(.-)%s*$")
--         if response ~= "y" then
--             return
--         end
--     else
--         return


end
return M
