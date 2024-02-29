-- An AsciiDoc (live) preview plugin
-- URL: https://github.com/tigion/nvim-asciidoc-preview

-- check plugin Neovim requirements
if vim.fn.has('nvim-0.8') ~= 1 then
  vim.opt_local.statusline = 'nvim-asciidoc-preview requires Neovim 0.8, or later'
  return
end

-- load plugin only once
if vim.g.tigion_asciidocPreview_loaded ~= nil then
  return
end

-- set neovim plugin variables
vim.g.tigion_asciidocPreview_loaded = true
vim.g.tigion_asciidocPreview_rootDir = vim.fn.expand('<sfile>:p:h:h')
vim.g.tigion_asciidocPreview_augroupName = 'tigionAsciidocPreview'

-- create auto commands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
augroup(vim.g.tigion_asciidocPreview_augroupName, { clear = true })
autocmd('BufEnter', {
  pattern = { '*.asc', '*.adoc', '*.asciidoc' },
  group = vim.g.tigion_asciidocPreview_augroupName,
  callback = function()
    -- create user commands (if needed)
    vim.api.nvim_create_user_command('AsciiDocPreview', require('asciidoc-preview').startServer, {})
  end,
})
