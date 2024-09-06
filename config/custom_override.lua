local wezterm = require('wezterm')
return {
   set_environment_variables = {
      PATH = '/opt/homebrew/bin:' .. os.getenv('PATH'),
   },
}
