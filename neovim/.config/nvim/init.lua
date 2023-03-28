require 'base'
require 'highlights'
require 'maps'
require 'plugins'
vim.notify = require 'notify'

require('notify').setup { background_colour = '#000000' }

local has = vim.fn.has
local is_mac = has "macunix"
local is_wsl = has "wsl"

if is_mac then
  require 'macos'
end
if is_wsl then
  require 'wsl'
end
