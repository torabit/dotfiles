vim.opt.clipboard = 'unnamedplus'

local g = vim.g
local fn = vim.fn
local win32yank = '/mnt/c/Tools/win32yank/win32yank.exe'

if fn.has("wsl") == 1 then
  g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = win32yank.." -i --crlf",
      ["*"] = win32yank.." -i --crlf",
    },
    paste = {
      ["+"] = win32yank.." -o --lf",
      ["*"] = win32yank.." -o --lf",
    },
    cache_enabled = true
  }
end
