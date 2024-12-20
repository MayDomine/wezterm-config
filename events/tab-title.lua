local wezterm = require('wezterm')

-- Inspired by https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614

local nf = wezterm.nerdfonts

local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]
local GLYPH_CIRCLE = nf.fa_circle --[[ '' ]]
local GLYPH_ADMIN = nf.md_shield_half_full --[[ '󰞀' ]]

local M = {}

local __cells__ = {} -- wezterm FormatItems (ref: https://wezfurlong.org/wezterm/config/lua/wezterm/format.html)

-- stylua: ignore
local colors = {
   default   = { bg = 'rgba(0, 72, 86, 1.0)', fg = 'rgba(28, 27, 25, 0.0)' },
   is_active = { bg = 'rgba(49, 187, 185, 1.0)', fg = 'rgba(17, 17, 27, 0.0)' },
   hover     = { bg = 'rgba(88, 125, 140, 1.0)', fg = 'rgba(28, 27, 25, 0.0)' },
}

local _set_process_name = function(s)
   local a = string.gsub(s, '(.*[/\\])(.*)', '%2')
   return a:gsub('%.exe$', '')
end

local _set_title = function(process_name, base_title, max_width, inset, tab)
   local title
   local min_width = 6  -- 设置一个最小宽度
   local max_width = 20
   inset = inset or 0
   process_name = tab.tab_title or process_name
    if process_name:len() > 0 then
        if tab.tab_title then
            title = tab.tab_title
        else
            title = process_name .. ' ~ ' .. base_title
        end
    else
        title = base_title
    end

   -- 截断过长的标题
   if title:len() > max_width - inset then
      local diff = title:len() - max_width + inset 
      title = wezterm.truncate_right(title, title:len() - diff)
   end

   -- 填充过短的标题
   if title:len() < min_width then
      title = title .. string.rep(' ', min_width - title:len())
   end
   return title
end

local _check_if_admin = function(p)
   if p:match('^Administrator: ') then
      return true
   end
   return false
end

---@param fg string
---@param bg string
---@param attribute table
---@param text string
local _push = function(bg, fg, attribute, text)
   table.insert(__cells__, { Background = { Color = bg } })
   table.insert(__cells__, { Foreground = { Color = fg } })
   table.insert(__cells__, { Attribute = attribute })
   table.insert(__cells__, { Text = text })
end

M.setup = function()
   wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, hover, max_width)
      __cells__ = {}

      local bg
      local fg
      local process_name = _set_process_name(tab.active_pane.foreground_process_name)
      local is_admin = _check_if_admin(tab.active_pane.title)
      local title = _set_title(process_name, tab.active_pane.title, max_width, (is_admin and 8), tab)

      if tab.is_active then
         bg = colors.is_active.bg
         fg = colors.is_active.fg
      elseif hover then
         bg = colors.hover.bg
         fg = colors.hover.fg
      else
         bg = colors.default.bg
         fg = colors.default.fg
      end

      local has_unseen_output = false
      for _, pane in ipairs(tab.panes) do
         if pane.has_unseen_output then
            has_unseen_output = true
            break
         end
      end
      local _tab_index = nil
      for i, tab_info in ipairs(_tabs) do
         if tab_info.tab_id == tab.tab_id then
             _tab_index = tab_info.tab_index + 1
            break
         end
      end

      -- Left semi-circle
      _push('rgba(0, 0, 0, 0)', bg, { Intensity = 'Bold' }, GLYPH_SEMI_CIRCLE_LEFT)

      -- Admin Icon
      if is_admin then
         _push(bg, fg, { Intensity = 'Bold' }, ' ' .. GLYPH_ADMIN)
      end

      -- Title
      _push(bg, fg, { Intensity = 'Bold' }, ' #' .. _tab_index)
      _push(bg, fg, { Intensity = 'Bold' }, ' ' .. title)

      -- Unseen output alert
      if has_unseen_output then
         _push(bg, '#FFA066', { Intensity = 'Bold' }, ' ' .. GLYPH_CIRCLE)
      end

      -- Right padding
      _push(bg, fg, { Intensity = 'Bold' }, ' ')

      -- Right semi-circle
      _push('rgba(0, 0, 0, 0)', bg, { Intensity = 'Bold' }, GLYPH_SEMI_CIRCLE_RIGHT)

      return __cells__
   end)
end

return M
