local util = require('asciidoc-preview.util')

local M = {}

-- Available option values
local CONVERTERS = { 'js', 'cmd' } -- Server converters
local NOTIFIES = { 'page' } -- Preview notification areas
local POSITIONS = { 'current', 'start', 'sync' } -- Preview positions
local REFRESHES = { 'save' } -- Preview refresh events

-- The plugins default options
local defaults = {
  -- Server options
  server = {
    -- Determines how the AsciiDoc file is converted to HTML for the preview.
    -- `js`  - Asciidoctor.js (no local installation needed)
    -- `cmd` - Asciidoctor command (local installation needed)
    converter = CONVERTERS[1],

    -- Determines the local port of the preview website.
    port = 11235,
  },
  -- Preview options
  preview = {
    -- Determines how the preview website should be refreshed.
    -- `page` - Entire website
    -- `body` - Body content -- TODO: not yet implemented
    notify = NOTIFIES[1],

    -- Determines the scroll position of the preview website.
    -- `current` - Keep current scroll position
    -- `start`   - Start of the website
    -- `sync`    - (experimental) Same (similar) position as in Neovim
    --           => inaccurate, because very content dependent
    position = POSITIONS[1],

    -- Determines when the preview website should be refreshed.
    -- `save` - Only when file is saved
    -- `live` - On content change -- TODO: not yet implemented (limit requests per time)
    refresh = REFRESHES[1],
  },
}

local root_dir = vim.g.tigion_asciidocPreview_rootDir
local server = {
  -- Server start script
  start = root_dir .. '/server/scripts/start.sh',
  -- Server URL with port
  url = 'http://localhost:' .. defaults.server.port,
  -- Server hi message for validation
  hi = 'Coffee please',
}

M.options = vim.deepcopy(defaults)
M.server = vim.deepcopy(server)

---Setting up with the user options.
---@param opts? table The table of user options
function M.setup(opts)
  -- Merged standard options with user options
  -- FIXME: Use defaults or M.options?
  M.options = vim.tbl_deep_extend('force', defaults, opts or {})
  -- M.options = vim.tbl_deep_extend('force', M.options, opts or {})

  -- Validated options
  M.options.server.converter = util.validatedValue(M.options.server.converter, CONVERTERS)
  M.options.server.port = 11235 -- TODO: check range or find next free port, hard-coded in server
  M.options.preview.notify = util.validatedValue(M.options.preview.notify, NOTIFIES)
  M.options.preview.position = util.validatedValue(M.options.preview.position, POSITIONS)
  M.options.preview.refresh = util.validatedValue(M.options.preview.refresh, REFRESHES)

  -- Set Server URL with port
  M.server.url = 'http://localhost:' .. M.options.server.port
end

return M
