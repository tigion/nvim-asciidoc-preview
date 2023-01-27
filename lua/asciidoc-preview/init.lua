-- init.lua

-- extra plugin.lua needed?

local server = require 'asciidoc-preview.server'
local helper = require 'asciidoc-preview.helper'
local config = require 'asciidoc-preview.config'

local M = {}

-- create auto commands
local function createAutocmds()
  -- https://neovim.io/doc/user/autocmd.html#autocmd-events
  local augroup = vim.api.nvim_create_augroup
  local autocmd = vim.api.nvim_create_autocmd
  local myAugroup = augroup(vim.g.tigion_asciidocPreview_augroupName, { clear = false })

  autocmd('VimLeavePre', {
    group = myAugroup,
    callback = function() require('asciidoc-preview').stopServer() end,
  })

  -- :h BufEnter
  -- :h BufWritePost
  -- :h TextChangedI (laggy and needs to send the buffer content)
  autocmd({ 'BufWritePost' }, {
    pattern = { '*.asc', '*.adoc', '*.asciidoc' },
    --buffer = 0, -- 0 = current buffer number
    group = myAugroup,
    callback = function()
      require('asciidoc-preview').sendFileToServer()
      require('asciidoc-preview').notifyServer()
    end,
  })
end

-- clear auto commands
local function clearAutocmds() vim.api.nvim_clear_autocmds { group = vim.g.tigion_asciidocPreview_augroupName } end

-- create user commands
local function createCommands()
  vim.api.nvim_create_user_command('AsciiDocPreviewNotify', require('asciidoc-preview').notifyServer, {})
  vim.api.nvim_create_user_command('AsciiDocPreviewOpen', require('asciidoc-preview').openBrowser, {})
  vim.api.nvim_create_user_command('AsciiDocPreviewStop', require('asciidoc-preview').stopServer, {})
end

-- delete user commands
local function deleteCommands()
  vim.api.nvim_del_user_command 'AsciiDocPreviewNotify'
  vim.api.nvim_del_user_command 'AsciiDocPreviewOpen'
  vim.api.nvim_del_user_command 'AsciiDocPreviewStop'
end

M.setup = config.setup

function M.startServer()
  createAutocmds()
  createCommands()
  server.start()
  if server.isRunning() then
    M.sendFileToServer()
    M.openBrowser() -- v1: here, v2: opens with node.js server
  end
end

function M.stopServer()
  server.stop()
  clearAutocmds()
  deleteCommands()
end

function M.sendFileToServer()
  local file = vim.fn.expand '%:p'
  server.sendFile(file)
end

function M.notifyServer()
  if config.options.notify.type == 'content' then
    server.sendContentNotify()
  else
    server.sendPageNotify()
  end
end

function M.openBrowser()
  local openCmd = helper.getOpenCmd()
  if openCmd ~= '' then io.popen(openCmd .. ' ' .. config.server.url) end
end

return M
