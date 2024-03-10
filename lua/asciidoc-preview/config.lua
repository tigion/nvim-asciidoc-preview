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
    -- `js`  - Asciidoctor.js (no local installation needed)
    -- `cmd` - Asciidoctor command (local installation needed)
    converter = 'js', ---@type converters

    -- Determines the local port of the preview website.
    port = 11235, ---@type integer
  },
  preview = {
    -- Determines how the preview website should be refreshed.
    -- `page` - Entire website
    -- `body` - Body content -- TODO: not yet implemented
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

---@type string
local root_dir = vim.g.tigion_asciidocPreview_rootDir

---@class AsciidocPreviewServer
---@field start string The filepath of the start script for the server
---@field url string The URL with port for the preview in the web browser
---@field hi string The validation message for the correct server
local server = {
  start = root_dir .. '/server/scripts/start.sh',
  url = 'http://localhost:' .. defaults.server.port,
  hi = 'Coffee please',
}

---@type AsciidocPreviewOptions
M.options = vim.deepcopy(defaults)

---@type AsciidocPreviewServer
M.server = vim.deepcopy(server)

---Setting up with the user options.
---@param opts? AsciidocPreviewOptions The table of user options
function M.setup(opts)
  -- Merged standard options with user options
  -- FIX: Use defaults or M.options?
  M.options = vim.tbl_deep_extend('force', defaults, opts or {})
  -- M.options = vim.tbl_deep_extend('force', M.options, opts or {})

  -- Validate options
  M.options.server.converter = util.validatedValue(M.options.server.converter, CONVERTERS, defaults.server.converter)
  M.options.server.port = 11235 -- TODO: check range or find next free port, hard-coded in server
  M.options.preview.notify = util.validatedValue(M.options.preview.notify, NOTIFIES, defaults.preview.notify)
  M.options.preview.position = util.validatedValue(M.options.preview.position, POSITIONS, defaults.preview.position)
  M.options.preview.refresh = util.validatedValue(M.options.preview.refresh, REFRESHES, defaults.preview.refresh)

  -- Set Server URL with port
  M.server.url = 'http://localhost:' .. M.options.server.port
end

return M
