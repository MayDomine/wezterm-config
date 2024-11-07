local wezterm = require('wezterm')
return {
   -- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
   ssh_domains = wezterm.default_ssh_domains(),
   -- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
   default_domain = 'local-socket',
   unix_domains = {
      {
         name = 'local-socket',
         socket_path = '/Users/tachicoma/.local/share/wezterm/sock',
      },
   },
   wsl_domains = {
      {
         name = 'WSL:Ubuntu',
         distribution = 'Ubuntu',
         username = 'kevin',
         default_cwd = '/home/kevin',
         default_prog = { 'fish', '-l' },
      },
   },
}
