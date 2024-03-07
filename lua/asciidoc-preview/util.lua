local M = {}

---Checks if the current OS is Windows.
---@return boolean
---@nodiscard
function M.is_windows()
  return package.config:sub(1, 1) == '\\'
end

---Returns a value if it is in a table of defaults.
---If not, the first value from the defaults is returned.
---@param value string The value to be validated
---@param defaults table A table with valid values for comparison
---@return string value The validated value
---@nodiscard
function M.validatedValue(value, defaults)
  -- vim.tbl_contains(defaults, value)
  for _, v in ipairs(defaults) do
    v = string.lower(v)
    value = string.lower(value)
    if v == value then
      return value
    end
  end
  value = string.lower(defaults[1] or '')
  return value
end

---Returns the root directory of the plugin.
---
--- FIXME: Optimize it or find a better alternative
---
---@return any
---@nodiscard
function M.getPluginPath()
  -- Variante 1: global editor variable
  local path = vim.g.tigion_asciidocPreview_rootDir
  if path then
    return path
  end

  -- Variante 2: debug library
  --print(vim.fn.stdpath('data'))
  --print(debug.getinfo(2, 'S').source:sub(2))
  local sep = package.config:sub(1, 1) -- `/` or `\\` (windows)
  path = debug.getinfo(2, 'S').source:sub(2) -- current file path
  local pattern = '(.*' .. sep .. ').*' .. sep .. '.*' .. sep
  path = path:match(pattern)
  return path
end

---Returns the platform-specific `open` command.
---
--- NOTE: Only macOS and Linux are currently supported.
--- TODO: FreeBSD, Windows, ...
---
---@return string
---@nodiscard
function M.getOpenCmd()
  local os = vim.loop.os_uname().sysname
  if os == 'Darwin' then
    return 'open'
  elseif os == 'Linux' then
    if vim.fn.has('wsl') == 1 then
      return 'wslview'
    else
      return 'xdg-open'
    end
  end

  print('Open browser on ' .. os .. ' not yet supported')
  return ''
end

---Returns the current line position in percent.
---@return number
---@nodiscard
function M.getCurrentLinePositionInPercent()
  local maxLine = vim.api.nvim_buf_line_count(0)
  local currentLine = vim.api.nvim_win_get_cursor(0)[1]
  local position = 100 * currentLine / maxLine
  return position
end

return M
