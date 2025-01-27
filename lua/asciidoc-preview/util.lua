local M = {}

-- ---Checks if the current OS is Windows.
-- ---@return boolean
-- ---@nodiscard
-- function M.is_windows()
--   return package.config:sub(1, 1) == '\\'
-- end

---Adds arguments to a command.
---@param cmd string
---@param args table
---@return string
---@nodiscard
function M.get_cmd_with_args(cmd, args)
  for _, arg in pairs(args) do
    cmd = ('%s %s %s'):format(cmd, arg.option, arg.parameter)
  end
  return cmd
end

---Returns a value if it is in a table of valid values.
---If not, the given default or the first valid value is returned.
---@param value string The value to be validated
---@param valid_values table A table with valid values for comparison
---@param default? string The default value if the value is not in the table
---@return string value The validated value
---@nodiscard
function M.validated_value(value, valid_values, default)
  -- NOTE: vim.tbl_contains(valid_values, value)
  for _, v in pairs(valid_values) do
    v = string.lower(v)
    value = string.lower(value)
    if v == value then
      return value
    end
  end
  return default or string.lower(valid_values[1] or '')
end

---Returns a valid port.
---If not, the given default port is returned.
--
-- TODO: If possible, do not specify a port.
--       Determine a free port from a certain value.
--
---@param port integer The port to be validated
---@param default integer The default port if the port is not valid
---@return integer port The validated port
---@nodiscard
function M.validated_port(port, default)
  if port < 10000 or port > 65535 then
    return default
  end
  return port
end

---Returns the root directory of the plugin.
---
--- FIX: Optimize it or find a better alternative
---
---@return any
---@nodiscard
function M.get_plugin_path()
  -- Variant 1: global editor variable
  local path = vim.g.tigion_asciidocPreview_rootDir
  if path then
    return path
  end

  -- Variant 2: debug library
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
function M.get_open_cmd()
  local os = vim.uv.os_uname().sysname
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
function M.get_current_line_position_in_percent()
  local max_line = vim.api.nvim_buf_line_count(0)
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local position = 100 * current_line / max_line
  return position
end

---Returns true if the current buffer type is asciidoc or asciidoctor.
---@param bufnr? number
---@return boolean
---@nodiscard
function M.is_asciidoc_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ft = vim.fn.getbufvar(bufnr, '&filetype')
  return ft == 'asciidoc' or ft == 'asciidoctor'
end

---Returns the list of asciidoc buffers.
---@return table
---@nodiscard
function M.get_asciidoc_buffers()
  local buffers = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if M.is_asciidoc_buffer(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
      table.insert(buffers, bufnr)
    end
  end
  return buffers
end

---Returns true if more than one loaded asciidoc buffer exists.
---@return boolean
---@nodiscard
function M.other_asciidoc_buffers_exists()
  if #M.get_asciidoc_buffers() > 1 then
    return true
  end
  return false
end

return M
