local util = require('asciidoc-preview.util')

---@class AsciidocPreviewConfig
local M = {}

---@enum converters
local CONVERTERS = { JS = 'js', CMD = 'cmd' } -- Server converters
---@enum notifies
local NOTIFIES = { PAGE = 'page' } -- Preview notification areas
---@enum positions
local POSITIONS = { CURRENT = 'current', START = 'start', SYNC = 'sync' } -- Preview positions
---@enum refreshes
local REFRESHES = { SAVE = 'save' } -- Preview refresh events

---@class AsciidocPreviewOptions
local defaults = {
  server = {
    -- Determines how the AsciiDoc file is converted to HTML for the preview.
    -- `js`  - asciidoctor.js (no local installation needed)
    -- `cmd` - asciidoctor command (local installation needed)
    converter = 'js', ---@type converters

    -- Determines the local port of the preview website.
    -- Must be between 10000 and 65535.
    port = 11235, ---@type integer
  },
  preview = {
    -- Determines how the preview website should be refreshed.
    -- `page` - Entire website
    -- `body` - Body content -- TODO: not yet ready implemented
    notify = 'page', ---@type notifies

    -- Determines the scroll position of the preview website.
    -- `current` - Keep current scroll position
    -- `start`   - Start of the website
    -- `sync`    - (experimental) Same (similar) position as in Neovim
    --           => inaccurate, because very content dependent
    position = 'current', ---@type positions

    -- Determines when the preview website should be refreshed.
    -- `save` - Only when file is saved
    -- `live` - On content change -- TODO: not yet implemented (limit requests per time)
    refresh = 'save', ---@type refreshes
  },
}

---@type AsciidocPreviewOptions
M.options = vim.deepcopy(defaults)

-- Set the needed directories
local root_dir = vim.g.tigion_asciidocPreview_rootDir ---@type string
local log_dir = vim.fn.stdpath('log') ---@type string
local cache_dir = vim.fn.stdpath('cache') ---@type string

---@class AsciidocPreviewServer
---@field start string The filepath of the start script for the server
---@field args table The arguments (option with parameter) for the start script
---@field url string The URL with port for the preview in the web browser
---@field hi string The validation message for the correct server
M.server = {
  start = ('"%s/server/scripts/start.sh"'):format(root_dir),
  args = {
    port = { option = '--port', parameter = M.options.server.port },
    log_dir = { option = '--logdir', parameter = ('"%s"'):format(log_dir) },
    cache_dir = { option = '--cachedir', parameter = ('"%s"'):format(cache_dir) },
  },
  url = 'http://localhost:' .. M.options.server.port,
  hi = 'Coffee please',
}

---@class AsciidocPreviewCommands
M.commands = {
  start = util.get_cmd_with_args(M.server.start, M.server.args),
  -- stylua: ignore start
  post_stop        = ('%s %s%s'):format('curl -s -X POST', M.server.url, '/api/actions/stop'),
  get_hi           = ('%s %s%s'):format('curl -s -X GET' , M.server.url, '/api/hi'),
  put_file         = ('%s %s%s'):format('curl -s -X PUT' , M.server.url, '/api/preview'),
  put_options      = ('%s %s%s'):format('curl -s -X PUT' , M.server.url, '/api/options'),
  post_notify_page = ('%s %s%s'):format('curl -s -X POST', M.server.url, '/api/actions/notify?type=page'),
  post_notify_body = ('%s %s%s'):format('curl -s -X POST', M.server.url, '/api/actions/notify?type=content'),
  -- stylua: ignore end
}

---Setting up with the user options.
---@param opts? AsciidocPreviewOptions The table of user options
function M.setup(opts)
  -- Merged standard options with user options
  -- FIX: Use defaults or M.options?
  M.options = vim.tbl_deep_extend('force', defaults, opts or {})
  -- M.options = vim.tbl_deep_extend('force', M.options, opts or {})

  -- Validate options
  M.options.server.converter = util.validated_value(M.options.server.converter, CONVERTERS, defaults.server.converter)
  M.options.server.port = util.validated_port(M.options.server.port, defaults.server.port)
  M.options.preview.notify = util.validated_value(M.options.preview.notify, NOTIFIES, defaults.preview.notify)
  M.options.preview.position = util.validated_value(M.options.preview.position, POSITIONS, defaults.preview.position)
  M.options.preview.refresh = util.validated_value(M.options.preview.refresh, REFRESHES, defaults.preview.refresh)

  -- FIX: Optimize validation and config setup of server and commands

  -- Set server URL with port
  M.server.args.port.parameter = M.options.server.port
  M.server.url = 'http://localhost:' .. M.options.server.port

  -- Set commands
  M.commands.start = util.get_cmd_with_args(M.server.start, M.server.args)
  -- stylua: ignore start
  M.commands.post_stop        = ('%s %s%s'):format('curl -s -X POST', M.server.url, '/api/actions/stop')
  M.commands.get_hi           = ('%s %s%s'):format('curl -s -X GET' , M.server.url, '/api/hi')
  M.commands.put_file         = ('%s %s%s'):format('curl -s -X PUT' , M.server.url, '/api/preview')
  M.commands.put_options      = ('%s %s%s'):format('curl -s -X PUT' , M.server.url, '/api/options')
  M.commands.post_notify_page = ('%s %s%s'):format('curl -s -X POST', M.server.url, '/api/actions/notify?type=page')
  M.commands.post_notify_body = ('%s %s%s'):format('curl -s -X POST', M.server.url, '/api/actions/notify?type=content')
  -- stylua: ignore end

  -- print('setup: ' .. vim.inspect(M.server))
  -- print('setup: ' .. vim.inspect(M.commands))
  -- print(M.commands.start)
end

return M
