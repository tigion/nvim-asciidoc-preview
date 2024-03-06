-- config.lua

local M = {}

local defaults = {
  asciidoc = {
    --[[
    converter to be used
    - js: (default) Asciidoctor.js (no local installation needed)
    - cmd: Asciidoctor command (local installation needed)
    --]]
    converter = 'js', -- js/cmd
  },
  notify = {
    --[[
    web page refresh type
    - page:    (default) entire web page
    - content: (not yet implemented) body content
    --]]
    type = 'page', -- page/content
  },
  preview = {
    --[[
    preview scroll (start) position after refresh
    - top:  always start from the top
    - last: (default) keep last (current) scroll position if possible
    - sync: (experimental) use relative position in percent to current Neovim line
            => inaccurate, because very content dependent
    --]]
    scroll = 'last', -- top/last/sync
  },
}

local path = vim.g.tigion_asciidocPreview_rootDir
local server = {
  start = path .. '/server/scripts/start.sh',
  url = 'http://localhost:11235', -- TODO: make port configurable
  hi = 'Coffee please',
}

M.options = {}
M.server = server

function M.setup(options)
  -- merge defaults with user options
  M.options = vim.tbl_deep_extend('force', {}, defaults, options or {})

  -- check options
  -- TODO: M.options.asciidoc.converter = 'js'
  M.options.notify.type = 'page' -- NOTE: force 'page', because 'content' is not yet implemented

  -- TODO: things needed for the setup
  -- - install with Lazy.nvim 'build' config (packer 'run')
  -- - Node.js server: npm install?
  -- - Autocmd?
end

M.setup()

return M
