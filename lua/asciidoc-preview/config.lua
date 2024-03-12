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

---@type string
local root_dir = vim.g.tigion_asciidocPreview_rootDir

---@class AsciidocPreviewServer
---@field start string The filepath of the start script for the server
---@field url string The URL with port for the preview in the web browser
---@field hi string The validation message for the correct server
M.server = {
  start = root_dir .. '/server/scripts/start.sh --port ' .. M.options.server.port,
  url = 'http://localhost:' .. M.options.server.port,
  hi = 'Coffee please',
}

---@class AsciidocPreviewApiURLs
M.apiURLs = {
  hi = M.server.url .. '/api/hi',
  file = M.server.url .. '/api/preview',
  options = M.server.url .. '/api/options',
  actions = {
    notify = {
      page = M.server.url .. '/api/actions/notify?type=page',
      content = M.server.url .. '/api/actions/notify?type=content',
    },
    stop = M.server.url .. '/api/actions/stop',
  },
}

---@class AsciidocPreviewCommands
M.commands = {
  start = M.server.start,
  postStop = 'curl -s -X POST ' .. M.apiURLs.actions.stop,
  getHi = 'curl -s -X GET ' .. M.apiURLs.hi,
  putFile = 'curl -s -X PUT ' .. M.apiURLs.file,
  putOptions = 'curl -s -X PUT ' .. M.apiURLs.options,
  postNotifyPage = 'curl -s -X POST ' .. M.apiURLs.actions.notify.page,
  postNotifyContent = 'curl -s -X POST ' .. M.apiURLs.actions.notify.content,
}

---Setting up with the user options.
---@param opts? AsciidocPreviewOptions The table of user options
function M.setup(opts)
  -- Merged standard options with user options
  -- FIX: Use defaults or M.options?
  M.options = vim.tbl_deep_extend('force', defaults, opts or {})
  -- M.options = vim.tbl_deep_extend('force', M.options, opts or {})

  -- Validate options
  M.options.server.converter = util.validatedValue(M.options.server.converter, CONVERTERS, defaults.server.converter)
  M.options.server.port = util.validatedPort(M.options.server.port, defaults.server.port)
  M.options.preview.notify = util.validatedValue(M.options.preview.notify, NOTIFIES, defaults.preview.notify)
  M.options.preview.position = util.validatedValue(M.options.preview.position, POSITIONS, defaults.preview.position)
  M.options.preview.refresh = util.validatedValue(M.options.preview.refresh, REFRESHES, defaults.preview.refresh)

  -- FIX: Optimize validation and config setup of server, apiURLs and commands

  -- Set Server URL with port
  M.server.start = root_dir .. '/server/scripts/start.sh --port ' .. M.options.server.port
  M.server.url = 'http://localhost:' .. M.options.server.port

  -- Set API URLs
  M.apiURLs.hi = M.server.url .. '/api/hi'
  M.apiURLs.file = M.server.url .. '/api/preview'
  M.apiURLs.options = M.server.url .. '/api/options'
  M.apiURLs.actions = {
    notify = {
      page = M.server.url .. '/api/actions/notify?type=page',
      content = M.server.url .. '/api/actions/notify?type=content',
    },
    stop = M.server.url .. '/api/actions/stop',
  }

  -- Set commands
  M.commands.start = M.server.start
  M.commands.postStop = 'curl -s -X POST ' .. M.apiURLs.actions.stop
  M.commands.getHi = 'curl -s -X GET ' .. M.apiURLs.hi
  M.commands.putFile = 'curl -s -X PUT ' .. M.apiURLs.file
  M.commands.putOptions = 'curl -s -X PUT ' .. M.apiURLs.options
  M.commands.postNotifyPage = 'curl -s -X POST ' .. M.apiURLs.actions.notify.page
  M.commands.postNotifyContent = 'curl -s -X POST ' .. M.apiURLs.actions.notify.content

  -- print('setup: ' .. vim.inspect(M.server))
  -- print('setup: ' .. vim.inspect(M.apiURLs))
  -- print('setup: ' .. vim.inspect(M.commands))
end

return M
