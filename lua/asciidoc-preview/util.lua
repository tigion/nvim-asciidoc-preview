local notify = require('asciidoc-preview.notify')

---@class asciidoc-preview.util
local M = {}

-- ---Checks if the current OS is Windows.
-- ---@return boolean
-- ---@nodiscard
-- function M.is_windows()
--   return package.config:sub(1, 1) == '\\'
-- end

---Adds arguments to a command.
---@param cmd string
---@param args asciidoc-preview.ServerArgs
---@return string
---@nodiscard
function M.get_cmd_with_args(cmd, args)
  for _, arg in pairs(args) do
    cmd = ('%s %s %s'):format(cmd, arg.option, arg.parameter)
  end
  return cmd
end

---Returns a value if it is in a table of valid values.
---If not, the given default or `nil` is returned.
---@param value string The value to be validated.
---@param valid_values table A table or list with valid values for comparison.
---@param default? string The default value if the value is not in the table.
---@return string? # The validated value.
---@nodiscard
function M.validated_value(value, valid_values, default)
  return vim.tbl_contains(valid_values, value) and value or default or nil
end

---Returns a valid port.
---If not, the given default port is returned.
--
-- TODO: If possible, do not specify a port.
--       Determine a free port from a certain value.
--
---@param port integer The port to be validated.
---@param default integer The default port if the port is not valid.
---@return integer port The validated port.
---@nodiscard
function M.validated_port(port, default)
  if port < 10000 or port > 65535 then return default end
  return port
end

---Returns the root directory of the plugin.
---
--- TODO: Optimize it or find a better alternative
---
---@return any
---@nodiscard
function M.get_plugin_path()
  -- Variant 1: global editor variable
  local path = vim.g.tigion_asciidocPreview_rootDir
  if path then return path end

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
---@return string?
---@nodiscard
function M.get_open_cmd()
  local os = vim.uv.os_uname().sysname

  -- if os == 'Darwin' then
  --   return 'open'
  -- elseif os == 'Linux' then
  --   if vim.fn.has('wsl') == 1 then
  --     return 'wslview'
  --   else
  --     return 'xdg-open'
  --   end
  -- end

  if vim.fn.has('mac') == 1 then
    -- macOS system
    return 'open'
  elseif vim.fn.has('linux') == 1 or vim.fn.has('bsd') == 1 then
    -- Linux or BSD system
    return 'xdg-open'
  elseif vim.fn.has('wsl') == 1 then
    -- Windows Subsystem for Linux
    return 'wslview'
  elseif vim.fn.has('win32') == 1 then
    -- Windows system (32 or 64 bit)
    return 'start'
  end

  notify.warn('Open browser on ' .. os .. ' not yet supported')
  return nil
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

---Returns true if the current buffer filetype is `asciidoc` or `asciidoctor`.
---@param bufnr? number
---@return boolean
---@nodiscard
function M.is_asciidoc_buffer(bufnr)
  return vim.list_contains({ 'asciidoc', 'asciidoctor' }, vim.bo[bufnr or 0].filetype)
end

---Returns a list of asciidoc buffers.
---@return integer[]
---@nodiscard
function M.get_asciidoc_buffers()
  local buffers = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if M.is_asciidoc_buffer(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then table.insert(buffers, bufnr) end
  end
  return buffers
end

---Returns true if more than one loaded asciidoc buffer exists.
---@return boolean
---@nodiscard
function M.other_asciidoc_buffers_exists() return #M.get_asciidoc_buffers() > 1 end

return M
