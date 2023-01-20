-- helper.lua

local M = {}

--function M.isWindows() return package.config:sub(1, 1) == '\\' end

-- get plugin path
function M.getPluginPath()
  -- variante 1: global editor variable
  local path = vim.g.tigion_asciidocPreview_rootDir
  if path then return path end

  -- variante 2: debug library
  --print(vim.fn.stdpath('data'))
  --print(debug.getinfo(2, 'S').source:sub(2))
  local sep = package.config:sub(1, 1) -- `/` or `\\` (windows)
  path = debug.getinfo(2, 'S').source:sub(2) -- current file path
  local pattern = '(.*' .. sep .. ').*' .. sep .. '.*' .. sep
  path = path:match(pattern)
  return path
end

-- get the platform-specific open command
function M.getOpenCmd()
  local os = vim.loop.os_uname().sysname
  if os == 'Darwin' then
    return 'open'
    --return 'open -a Safari'
  elseif os == 'Linux' then
    return 'xdg-open'
  end

  -- FreeBSD, OpenBSD, Windows, ...
  print('TODO: Open browser on ' .. os .. ' not yet supported')
  return ''
end

return M
