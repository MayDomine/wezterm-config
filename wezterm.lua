local Config = require('config')
require('utils.backdrops'):set_files():random()

require('events.right-status').setup()
require('events.left-status').setup()
require('events.tab-title').setup()
require('events.new-tab-button').setup()
local c = Config:init()
   :append(require('config.appearance'))
   :append(require('config.bindings'))
   :append(require('config.domains'))
   :append(require('config.fonts'))
   :append(require('config.general'))
   :append(require('config.launch'))
local opt = c.options
local custom_opt = require('config.custom_override')
for k, v in pairs(custom_opt) do
   if custom_opt[k] ~= nil then
      opt[k] = v
   end
end
return opt
