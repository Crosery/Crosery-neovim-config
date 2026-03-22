package.path = package.path .. ";/home/crosery/.luarocks/share/lua/5.1/?.lua;/home/crosery/.luarocks/share/lua/5.1/?/init.lua"
package.cpath = package.cpath .. ";/home/crosery/.luarocks/lib/lua/5.1/?.so"

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
