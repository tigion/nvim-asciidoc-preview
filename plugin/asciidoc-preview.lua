-- An AsciiDoc (live) preview plugin
-- URL: https://github.com/tigion/nvim-asciidoc-preview

-- Check plugin Neovim requirements
if vim.fn.has('nvim-0.8') ~= 1 then
  vim.opt_local.statusline = 'nvim-asciidoc-preview requires Neovim 0.8, or later'
  return
end

-- Load plugin only once
if vim.g.tigion_asciidocPreview_loaded ~= nil then
  return
end

-- Set neovim plugin variables
vim.g.tigion_asciidocPreview_loaded = true
vim.g.tigion_asciidocPreview_rootDir = vim.fn.expand('<sfile>:p:h:h')
vim.g.tigion_asciidocPreview_augroupName = 'tigionAsciidocPreview'
vim.g.tigion_asciidocPreview_isStarted = false

-- Checks if the plugin directory is writable
local plugin_dir = vim.g.tigion_asciidocPreview_rootDir
if vim.fn.filewritable(plugin_dir) ~= 2 then
  vim.notify('nvim-asciidoc-preview: Plugin directory is not writable!', vim.log.levels.WARN)
  vim.notify('Run `:checkhealth asciidoc-preview` to check the health of the plugin.', vim.log.levels.INFO)
end

-- Creates auto commands
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
augroup(vim.g.tigion_asciidocPreview_augroupName, { clear = true })
-- Creates auto commands for filetype `asciidoc` and `asciidoctor`.
autocmd('FileType', {
  pattern = { 'asciidoc', 'asciidoctor' },
  group = vim.g.tigion_asciidocPreview_augroupName,
  callback = function()
    -- Creates user commands
    vim.api.nvim_buf_create_user_command(0, 'AsciiDocPreview', require('asciidoc-preview').start_server, {})
    if vim.g.tigion_asciidocPreview_isStarted then
      require('asciidoc-preview').create_user_commands()
    end
  end,
})
