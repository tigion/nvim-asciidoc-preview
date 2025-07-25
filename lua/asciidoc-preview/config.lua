local util = require('asciidoc-preview.util')

---@class asciidoc-preview.config
local M = {}

---@enum converters
M.CONVERTERS = { JS = 'js', CMD = 'cmd' } -- Server converters
---@enum notifies
M.NOTIFIES = { PAGE = 'page' } -- Preview notification areas
---@enum positions
M.POSITIONS = { CURRENT = 'current', START = 'start', SYNC = 'sync' } -- Preview positions
---@enum refreshes
M.REFRESHES = { SAVE = 'save' } -- Preview refresh events

---@class asciidoc-preview.ConfigServer
---@field converter? converters
---@field port? integer

---@class asciidoc-preview.ConfigPreview
---@field notify? notifies
---@field position? positions
---@field refresh? refreshes

---@class asciidoc-preview.Config
---@field server? asciidoc-preview.ConfigServer
---@field preview? asciidoc-preview.ConfigPreview

---@type asciidoc-preview.Config
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

---@type asciidoc-preview.Config
M.options = vim.deepcopy(defaults)

-- Set the needed directories
local root_dir = vim.g.tigion_asciidocPreview_rootDir ---@type string
local log_dir = vim.fn.stdpath('log') ---@type string
local cache_dir = vim.fn.stdpath('cache') ---@type string

---@class asciidoc-preview.ServerArg
---@field option string
---@field parameter string|integer

---@class asciidoc-preview.ServerArgs
---@field port asciidoc-preview.ServerArg
---@field log_dir asciidoc-preview.ServerArg
---@field cache_dir asciidoc-preview.ServerArg

---@class asciidoc-preview.Server
---@field start string The filepath of the start script for the server
---@field args asciidoc-preview.ServerArgs The arguments (option with parameter) for the start script
---@field url string The URL with port for the preview in the web browser
---@field hi string The validation message for the correct server

---@type asciidoc-preview.Server
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

---@class asciidoc-preview.Commands
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

---Sets up the plugin with the given user options.
---@param opts? asciidoc-preview.Config The table of user options.
function M.setup(opts)
  -- Merges the user config with the default config.
  M.options = vim.tbl_deep_extend('force', defaults, opts or {})

  -- Validate options
  M.options.server.converter = util.validated_value(M.options.server.converter, M.CONVERTERS, defaults.server.converter)
  M.options.server.port = util.validated_port(M.options.server.port, defaults.server.port)
  M.options.preview.notify = util.validated_value(M.options.preview.notify, M.NOTIFIES, defaults.preview.notify)
  M.options.preview.position = util.validated_value(M.options.preview.position, M.POSITIONS, defaults.preview.position)
  M.options.preview.refresh = util.validated_value(M.options.preview.refresh, M.REFRESHES, defaults.preview.refresh)

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
