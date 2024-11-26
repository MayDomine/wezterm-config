-- A slightly altered version of catppucchin mocha
local mocha = {
   rosewater = '#f5e0dc',
  white = '#DDDDDD',
   flamingo = '#f2cdcd',
   pink = '#f5c2e7',
   mauve = '#cba6f7',
   red = '#f38ba8',
   maroon = '#eba0ac',
   peach = '#fab387',
   yellow = '#f9e2af',
   green = '#a6e3a1',
   teal = '#94e2d5',
   sky = '#89dceb',
   sapphire = '#74c7ec',
   blue = '#89b4fa',
   lavender = '#b4befe',
   text = '#cdd6f4',
   subtext1 = '#bac2de',
   subtext0 = '#a6adc8',
   overlay2 = '#9399b2',
   overlay1 = '#7f849c',
   overlay0 = '#6c7086',
   surface2 = '#585b70',
   surface1 = '#45475a',
   surface0 = '#313244',
   base = '#1f1f28',
   kitty_blue = '#031E2B',
  kitty_curosr = "#59e1e3",
   mantle = '#181825',
   crust = '#11111b',
}

local colorscheme = {
   foreground = mocha.white,
   background = mocha.kitty_blue,
   cursor_bg = mocha.kitty_curosr,
   cursor_border = mocha.rosewater,
   cursor_fg = mocha.crust,
   selection_bg = mocha.surface2,
   selection_fg = mocha.text,
   ansi = {
      '#0C0C0C', -- black
      '#ff16b0', -- red
      '#b3f361', -- green
      '#C19C00', -- yellow
      '#0037DA', -- blue
      '#881798', -- magenta/purple
      '#59e1e3', -- cyan
      '#CCCCCC', -- white
   },
   brights = {
      '#767676', -- black
      '#E74856', -- red
      '#b3f361', -- green
      '#ffea16', -- yellow
      '#3B78FF', -- blue
      '#B4009E', -- magenta/purple
      '#59e1e3', -- cyan
      '#F2F2F2', -- white
   },
   tab_bar = {
      background = 'rgba(0, 0, 0, 0)',
      active_tab = {
         bg_color = mocha.surface0,
         fg_color = mocha.text,
      },
      inactive_tab = {
         bg_color = mocha.surface0,
         fg_color = mocha.subtext1,
      },
      inactive_tab_hover = {
         bg_color = mocha.surface0,
         fg_color = mocha.text,
      },
      new_tab = {
         bg_color = 'rgba(0, 0, 0, 0)',
         fg_color = mocha.text,
      },
      new_tab_hover = {
         bg_color = mocha.mantle,
         fg_color = mocha.text,
         italic = true,
      },
   },
   visual_bell = mocha.surface0,
   indexed = {
      [16] = mocha.peach,
      [17] = mocha.rosewater,
   },
   scrollbar_thumb = mocha.surface2,
   split = mocha.overlay0,
   compose_cursor = mocha.flamingo, -- nightbuild only
}

return colorscheme
