-- config.lua

local M = {}

local defaults = {
  asciidoc = {
    converter = 'js', -- 'js' or 'cmd'
  },
  notify = {
    type = 'page', -- 'page' or 'content'
  },
}

local path = vim.g.tigion_asciidocPreview_rootDir
local server = {
  start = path .. '/server/scripts/start.sh',
  url = 'http://localhost:11235',
  hi = 'Coffee please',
}

M.options = {}
M.server = server

function M.setup(options)
  -- merge defaults with user options
  M.options = vim.tbl_deep_extend('force', {}, defaults, options or {})

  -- check options
  M.options.notify.type = 'page' -- force 'page', TODO: 'content' not yet implemented

  -- TODO: things needed for the setup
  -- - Node.js server: npm install?
  -- - Autocmd?
end

M.setup()

return M
