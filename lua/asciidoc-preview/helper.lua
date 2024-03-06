-- helper.lua

local M = {}

--function M.isWindows() return package.config:sub(1, 1) == '\\' end

-- get plugin path
function M.getPluginPath()
  -- variante 1: global editor variable
  local path = vim.g.tigion_asciidocPreview_rootDir
  if path then
    return path
  end

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
    if vim.fn.has('wsl') == 1 then
      return 'wslview'
    else
      return 'xdg-open'
    end
  end

  -- FreeBSD, OpenBSD, Windows, ...
  print('TODO: Open browser on ' .. os .. ' not yet supported')
  return ''
end

-- calculate current line position in percent
function M.getCurrentLinePositionInPercent()
  local maxLine = vim.api.nvim_buf_line_count(0)
  local currentLine = vim.api.nvim_win_get_cursor(0)[1]
  local position = 100 * currentLine / maxLine
  return position
end

return M
