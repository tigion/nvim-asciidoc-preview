local util = require('asciidoc-preview.util')
local config = require('asciidoc-preview.config')
local server = require('asciidoc-preview.server')

local M = {}

-- Creates auto commands
local function create_auto_commands()
  -- https://neovim.io/doc/user/autocmd.html#autocmd-events
  local augroup = vim.api.nvim_create_augroup
  local autocmd = vim.api.nvim_create_autocmd
  local my_augroup = augroup(vim.g.tigion_asciidocPreview_augroupName, { clear = false })

  -- Stops the preview when leaving Neovim
  autocmd('VimLeavePre', {
    group = my_augroup,
    callback = function()
      require('asciidoc-preview').stop_server()
    end,
  })

  -- Stops the preview when no other AsciiDoc buffers exists.
  autocmd('BufUnload', {
    pattern = { '*.asc', '*.adoc', '*.asciidoc' },
    group = my_augroup,
    callback = function()
      if not util.other_asciidoc_buffers_exists() then
        require('asciidoc-preview').stop_server()
      end
    end,
  })

  -- Refreshes the preview when opening, saving or switching an AsciiDoc file.
  --
  -- NOTE: In some cases `BufEnter` does not fire, so we use also `WinEnter`
  --
  -- TODO: TextChanged, TextChangedI
  --       - laggy: needs time framed and to send the buffer content
  --
  autocmd({ 'BufEnter', 'WinEnter', 'BufWritePost' }, {
    pattern = { '*.asc', '*.adoc', '*.asciidoc' },
    --buffer = 0, -- 0 = current buffer number
    group = my_augroup,
    callback = function()
      require('asciidoc-preview').send_file_to_server()
      require('asciidoc-preview').notify_server()
    end,
  })
end

-- Clears auto commands.
local function clear_auto_commands()
  vim.api.nvim_clear_autocmds({ group = vim.g.tigion_asciidocPreview_augroupName })
end

---Creates user commands in current or given asciidoc buffer.
---@param bufnr? number
function M.create_user_commands(bufnr)
  bufnr = bufnr or 0 -- `0` is an alias for current buffer number
  vim.api.nvim_buf_create_user_command(bufnr, 'AsciiDocPreviewNotify', require('asciidoc-preview').notify_server, {})
  vim.api.nvim_buf_create_user_command(bufnr, 'AsciiDocPreviewOpen', require('asciidoc-preview').open_browser, {})
  vim.api.nvim_buf_create_user_command(bufnr, 'AsciiDocPreviewStop', require('asciidoc-preview').stop_server, {})
end

-- Creates user commands in all asciidoc buffers.
function M.create_user_commands_all()
  for _, bufnr in ipairs(util.get_asciidoc_buffers()) do
    M.create_user_commands(bufnr)
  end
end

-- Deletes user commands in all asciidoc buffers.
local function delete_user_commands_all()
  for _, bufnr in ipairs(util.get_asciidoc_buffers()) do
    vim.api.nvim_buf_del_user_command(bufnr, 'AsciiDocPreviewNotify')
    vim.api.nvim_buf_del_user_command(bufnr, 'AsciiDocPreviewOpen')
    vim.api.nvim_buf_del_user_command(bufnr, 'AsciiDocPreviewStop')
  end
end

-- Setting up
M.setup = config.setup
-- M.setup = function(opts)
--   -- print('setup: ' .. vim.inspect(opts))
--   config.setup(opts)
-- end

-- Gets things ready and start the server.
-- When started, open the preview in the web browser.
function M.start_server()
  if not util.is_asciidoc_buffer() then
    vim.notify(
      'nvim-asciidoc-preview: The preview can only be started if you are in an AsciiDoc file.',
      vim.log.levels.WARN
    )
    return
  end
  create_auto_commands()
  M.create_user_commands_all()
  server.start()
  if server.is_running() then
    vim.g.tigion_asciidocPreview_isStarted = true
    server.send_options()
    M.send_file_to_server()
    M.open_browser() -- v1: here, v2: opens with node.js server
  else
    vim.notify('nvim-asciidoc-preview: Preview server failed to start.', vim.log.levels.WARN)
    vim.notify('Run `:checkhealth asciidoc-preview` to check the health of the plugin.', vim.log.levels.INFO)
    M.stop_server()
  end
end

-- Stops the server and clean things up.
function M.stop_server()
  vim.g.tigion_asciidocPreview_isStarted = false
  server.stop()
  clear_auto_commands()
  delete_user_commands_all()
end

-- Sends a file to the server.
function M.send_file_to_server()
  local filepath = vim.fn.expand('%:p') -- file in the editor with full path
  local preview_position = -1 -- current scroll position
  if config.options.preview.position == 'start' then
    preview_position = 0 -- start of the website
  elseif config.options.preview.position == 'sync' then
    preview_position = util.get_current_line_position_in_percent() -- same (similar) position as in Neovim
  end
  server.send_file(filepath, preview_position)
end

-- Sends a notification to the server to refresh the preview page.
function M.notify_server()
  if config.options.preview.notify == 'content' then
    server.send_content_notify() -- notify content
  else
    server.send_page_notify() -- notify page
  end
end

-- Opens the preview in the web browser.
function M.open_browser()
  local open_cmd = util.get_open_cmd()
  if open_cmd ~= '' then
    io.popen(open_cmd .. ' ' .. config.server.url)
  end
end

return M
