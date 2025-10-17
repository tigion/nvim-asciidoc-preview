---@class asciidoc-preview.health
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
  local os = vim.uv.os_uname().sysname

  if vim.fn.has('mac') == 1 then
    ok('macOS (`' .. os .. '`) is supported')
  elseif vim.fn.has('linux') == 1 then
    -- NOTE: NixOS is not yet supported!
    --       Write permissions of the plugin directory are currently a problem on NixOS.
    ok('Linux (`' .. os .. '`) is supported (with limitations, e.g. NixOS)')
  elseif vim.fn.has('wsl') == 1 then
    warn('Windows WSL (`' .. os .. '`) is supported (with limitations)')
  else
    error('Operating system (`' .. os .. '`) is not supported or not yet tested')
  end
end

---Checks if the given executable is installed.
---@param cmd_name string The command name without arguments.
---@param opts? {optional?: boolean, show_version?: boolean, version_cmd?: string} Additional options.
---@return boolean True if the executable is installed, false otherwise.
local function check_executable(cmd_name, opts)
  opts = opts or {}
  if opts.optional == nil then opts.optional = false end
  if opts.show_version == nil then opts.show_version = true end

  if vim.fn.executable(cmd_name) == 1 then
    local cmd_version = nil
    if opts.show_version then
      local version_cmd = opts.version_cmd or (cmd_name .. ' --version')
      local version = (vim.fn.systemlist(version_cmd)[1] or '')
      if #version > 80 then version = version:sub(1, 80) .. '…' end
      cmd_version = '`' .. (version ~= '' and version or 'unknown version') .. '`'
    end
    ok(cmd_name .. ': ' .. (cmd_version or 'is installed'))
    return true
  elseif opts.optional then
    warn(cmd_name .. ': is not installed')
  else
    error(cmd_name .. ': is not installed')
  end
  return false
end

---Checks if the given ruby gem is installed.
---@param gem_name string The gem name.
---@param opts? {optional?: boolean} Additional options.
local function check_ruby_gem(gem_name, opts)
  opts = opts or {}
  if opts.optional == nil then opts.optional = false end

  local version = vim.fn.system("gem list | grep '^" .. gem_name .. " .*$'"):match('%((.*)%)')
  if vim.v.shell_error == 0 then
    ok('gem ' .. gem_name .. ': `' .. (version or 'unknown version') .. '`')
  elseif opts.optional then
    warn('gem ' .. gem_name .. ': not installed')
  else
    error('gem ' .. gem_name .. ': not installed')
  end
end

---Checks required core tools.
local function check_core_tools()
  check_executable('node')
  check_executable('npm')
  check_executable('curl')
end

---Checks if the given directory is writable.
---@param dir string The directory path.
---@param name? string The optional Directory display name.
local function check_directory(dir, name)
  if dir == nil then
    error((name or 'Directory') .. ' is not specified')
    return
  end
  if vim.fn.isdirectory(dir) ~= 1 then
    error('Directory `' .. dir .. '` does not exist')
    return
  end
  local message = (name or 'Directory') .. ' `' .. dir .. '` is '
  if vim.fn.filewritable(dir) == 2 then
    ok(message .. 'writable')
  else
    error(message .. 'not writable')
  end
end

---Checks required directories.
local function check_directories()
  -- Plugin directory must be writable to allow installation of the needed node modules.
  if vim.g.tigion_asciidocPreview_rootDir == nil then
    error('Plugin directory is not set (variable `tigion_asciidocPreview_rootDir` is nil)')
  else
    check_directory(vim.g.tigion_asciidocPreview_rootDir, 'Plugin directory')
  end
  -- Log directory must be writable to write log files.
  local dir = vim.fn.stdpath('log')
  check_directory(dir, 'Log directory')
  -- Cache directory must be writable to store temporary files for the html preview.
  dir = vim.fn.stdpath('cache')
  check_directory(dir, 'Cache directory')
end

---Checks required Asciidoctor tools.
local function check_asciidoctor()
  info(
    'The following warnings or errors are only relevant\n'
      .. "if a local installed Asciidoctor (`converter = 'cmd'`) is used."
  )
  check_executable('asciidoctor', { optional = true })
  check_executable('ruby', { optional = true })
  local has_gem = check_executable('gem', { optional = true })
  if has_gem then
    check_ruby_gem('asciidoctor', { optional = true })
    check_ruby_gem('asciidoctor-diagram', { optional = true })
  else
    info('Skipping ruby gem checks because `gem` command is not available.')
  end
  info('More ruby gems can be needed depending on the used Asciidoctor extensions.')
end

---Checks the health of the plugin.
function M.check()
  start('nvim-asciidoc-preview')
  check_supported_os()
  check_core_tools()
  check_directories()

  start('Asciidoctor (optional)')
  check_asciidoctor()
end

return M
