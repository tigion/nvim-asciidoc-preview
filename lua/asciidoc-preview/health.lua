local M = {}

-- The "report_" prefix has been deprecated, use the recommended replacements if they exist.
-- stylua: ignore start
local start = vim.health.start or vim.health.report_start -- Starts a new report or section.
local ok    = vim.health.ok    or vim.health.report_ok    -- Reports a success message.
local warn  = vim.health.warn  or vim.health.report_warn  -- Reports a warning.
local info  = vim.health.info  or vim.health.report_info  -- Reports an informational message.
local error = vim.health.error or vim.health.report_error -- Reports an error.
-- stylua: ignore end

---Checks if the current OS is supported.
local function check_supported_os()
  local os = vim.loop.os_uname().sysname

  if vim.fn.has('mac') then
    ok('macOS (' .. os .. ') supported')
  elseif vim.fn.has('linux') then
    ok('Linux (' .. os .. ') supported')
  elseif vim.fn.has('wsl') then
    warn('Windows WSL (' .. os .. ') not supported or not yet tested')
  else
    error('Operating system (' .. os .. ') not supported or not yet tested')
  end
end

---Checks if the given executable is installed.
---@param name string Command name without arguments
---@param optional? boolean Optional flag
local function check_executable(name, optional)
  if vim.fn.executable(name) == 1 then
    ok(name .. ' installed')
  elseif optional or false then
    warn(name .. ' not installed')
  else
    error(name .. ' not installed')
  end
end

---Checks if the given ruby gem is installed.
---@param name string Gem name
---@param optional? boolean Optional flag
local function check_ruby_gem(name, optional)
  vim.fn.system('gem list --no-version | grep -q "^' .. name .. '$"')
  if vim.v.shell_error == 0 then
    ok(name .. ' gem installed')
  elseif optional or false then
    warn(name .. ' gem not installed')
  else
    error(name .. ' gem not installed')
  end
end

---Checks required core tools.
local function check_core_tools()
  check_executable('node')
  check_executable('npm')
  check_executable('curl')
end

---Checks required Asciidoctor tools.
local function check_asciidoctor()
  info("The following warnings or errors can be ignored\nif Asciidoctor.js (`converter = 'js'`) is used.")
  check_executable('asciidoctor', true)
  check_executable('ruby', true)
  check_ruby_gem('asciidoctor', true)
  check_ruby_gem('asciidoctor-diagram', true)
end

---Checks the health of the plugin.
function M.check()
  start('nvim-asciidoc-preview')
  check_supported_os()
  check_core_tools()

  start('Asciidoctor (optional)')
  check_asciidoctor()
end

return M
