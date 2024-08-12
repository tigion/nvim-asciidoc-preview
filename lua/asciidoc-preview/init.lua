local util = require('asciidoc-preview.util')
local config = require('asciidoc-preview.config')
local server = require('asciidoc-preview.server')

local M = {}

-- Creates auto commands
local function createAutoCommands()
  -- https://neovim.io/doc/user/autocmd.html#autocmd-events
  local augroup = vim.api.nvim_create_augroup
  local autocmd = vim.api.nvim_create_autocmd
  local myAugroup = augroup(vim.g.tigion_asciidocPreview_augroupName, { clear = false })

  -- Stops the preview when leaving Neovim
  autocmd('VimLeavePre', {
    group = myAugroup,
    callback = function()
      require('asciidoc-preview').stopServer()
    end,
  })

  -- Stops the preview when no other AsciiDoc buffers exists.
  autocmd('BufUnload', {
    pattern = { '*.asc', '*.adoc', '*.asciidoc' },
    group = myAugroup,
    callback = function()
      if not util.other_asciidoc_buffers_exists() then
        require('asciidoc-preview').stopServer()
      end
    end,
  })

  -- Refreshes the preview when opening, saving or switching an AsciiDoc file.
  --
  -- NOTE: In some cases `BufEnter` does not fire, so we use `WinEnter`
  --
  -- TODO: TextChanged, TextChangedI
  --       - laggy: needs time framed and to send the buffer content
  --
  autocmd({ 'WinEnter', 'BufWritePost' }, {
    pattern = { '*.asc', '*.adoc', '*.asciidoc' },
    --buffer = 0, -- 0 = current buffer number
    group = myAugroup,
    callback = function()
      require('asciidoc-preview').sendFileToServer()
      require('asciidoc-preview').notifyServer()
    end,
  })
end

-- Clears auto commands
local function clearAutoCommands()
  vim.api.nvim_clear_autocmds({ group = vim.g.tigion_asciidocPreview_augroupName })
end

-- Creates user commands
local function createUserCommands()
  vim.api.nvim_create_user_command('AsciiDocPreviewNotify', require('asciidoc-preview').notifyServer, {})
  vim.api.nvim_create_user_command('AsciiDocPreviewOpen', require('asciidoc-preview').openBrowser, {})
  vim.api.nvim_create_user_command('AsciiDocPreviewStop', require('asciidoc-preview').stopServer, {})
end

-- Deletes user commands
local function deleteUserCommands()
  vim.api.nvim_del_user_command('AsciiDocPreviewNotify')
  vim.api.nvim_del_user_command('AsciiDocPreviewOpen')
  vim.api.nvim_del_user_command('AsciiDocPreviewStop')
end

-- Setting up
M.setup = config.setup
-- M.setup = function(opts)
--   -- print('setup: ' .. vim.inspect(opts))
--   config.setup(opts)
-- end

-- Gets things ready and start the server.
-- When started, open the preview in the web browser.
function M.startServer()
  if not util.is_asciidoc_buffer() then
    vim.notify(
      'nvim-asciidoc-preview: The preview can only be started if you are in an AsciiDoc file.',
      vim.log.levels.WARN
    )
    return
  end
  createAutoCommands()
  createUserCommands()
  server.start()
  if server.isRunning() then
    server.sendOptions()
    M.sendFileToServer()
    M.openBrowser() -- v1: here, v2: opens with node.js server
  else
    vim.notify('nvim-asciidoc-preview: Preview server failed to start.', vim.log.levels.WARN)
    vim.notify('Run `:checkhealth asciidoc-preview` to check the health of the plugin.', vim.log.levels.INFO)
    M.stopServer()
  end
end

-- Stops the server and clean things up.
function M.stopServer()
  server.stop()
  clearAutoCommands()
  deleteUserCommands()
end

-- Sends a file to the server.
function M.sendFileToServer()
  local filepath = vim.fn.expand('%:p') -- file in the editor with full path
  local preview_position = -1 -- current scroll position
  if config.options.preview.position == 'start' then
    preview_position = 0 -- start of the website
  elseif config.options.preview.position == 'sync' then
    preview_position = util.getCurrentLinePositionInPercent() -- same (similar) position as in Neovim
  end
  server.sendFile(filepath, preview_position)
end

-- Sends a notification to the server to refresh the preview page.
function M.notifyServer()
  if config.options.preview.notify == 'content' then
    server.sendContentNotify() -- notify content
  else
    server.sendPageNotify() -- notify page
  end
end

-- Opens the preview in the web browser.
function M.openBrowser()
  local openCmd = util.getOpenCmd()
  if openCmd ~= '' then
    io.popen(openCmd .. ' ' .. config.server.url)
  end
end

return M
