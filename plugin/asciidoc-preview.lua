-- An AsciiDoc (live) preview plugin.
-- URL: https://github.com/tigion/nvim-asciidoc-preview

local notify = require('asciidoc-preview.notify')

-- Stops the plugin if Neovim does not have the required minimum version.
if vim.fn.has('nvim-0.10') ~= 1 then
  notify.error('nvim-asciidoc-preview requires Neovim >= 0.10')
  return
end

-- Prevents the plugin from being loaded multiple times.
if vim.g.tigion_asciidocPreview_loaded ~= nil then return end

-- Sets the required global Neovim (Vimscript) variables.
vim.g.tigion_asciidocPreview_loaded = true
vim.g.tigion_asciidocPreview_rootDir = vim.fn.expand('<sfile>:p:h:h')
vim.g.tigion_asciidocPreview_augroupName = 'tigionAsciidocPreview'
vim.g.tigion_asciidocPreview_isStarted = false

-- Warns the user if the plugin directory is not writable.
local plugin_dir = vim.g.tigion_asciidocPreview_rootDir
if vim.fn.filewritable(plugin_dir) ~= 2 then
  notify.warn('Plugin directory is not writable!', { show_check_health = true })
end

-- Adds an autocommand event handler that creates the buffer-local
-- user commands only for supported filetypes.
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
augroup(vim.g.tigion_asciidocPreview_augroupName, { clear = true })
autocmd('FileType', {
  pattern = { 'asciidoc', 'asciidoctor' },
  group = vim.g.tigion_asciidocPreview_augroupName,
  callback = function()
    -- Creates only the initial user command to start the preview.
    vim.api.nvim_buf_create_user_command(0, 'AsciiDocPreview', require('asciidoc-preview').start_server, {})
    -- Creates all other user commands if the server has already been started.
    if vim.g.tigion_asciidocPreview_isStarted then require('asciidoc-preview').create_user_commands() end
  end,
})
