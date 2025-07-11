local config = require('asciidoc-preview.config')
local notify = require('asciidoc-preview.notify')
local server = require('asciidoc-preview.server')
local util = require('asciidoc-preview.util')

---@class asciidoc-preview
local M = {}

---Adds the autocommand event handlers to stop or refresh the preview.
-- - https://neovim.io/doc/user/autocmd.html#autocmd-events
local function create_auto_commands()
  local augroup = vim.api.nvim_create_augroup
  local autocmd = vim.api.nvim_create_autocmd
  local my_augroup = augroup(vim.g.tigion_asciidocPreview_augroupName, { clear = false })

  -- Stops the preview when exiting Neovim.
  autocmd('VimLeavePre', {
    group = my_augroup,
    callback = function() require('asciidoc-preview').stop_server() end,
  })

  -- Stops the preview when no other AsciiDoc buffers exists.
  autocmd('BufUnload', {
    pattern = { '*.asc', '*.adoc', '*.asciidoc' },
    group = my_augroup,
    callback = function()
      if not util.other_asciidoc_buffers_exists() then require('asciidoc-preview').stop_server() end
    end,
  })

  -- Refreshes the preview when opening, saving or switching an AsciiDoc file.
  --
  -- NOTE: In some cases `BufEnter` does not fire, so we use also `WinEnter`
  --
  -- TODO: TextChanged, TextChangedI
  --       - laggy: Needs time framed and to send the unsaved buffer content.
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

---Removes all added autocommand event handlers.
local function clear_auto_commands() vim.api.nvim_clear_autocmds({ group = vim.g.tigion_asciidocPreview_augroupName }) end

---Creates the additional buffer-local user commands to interact
---with the running preview in the current or given buffer.
---@param bufnr? number -- The buffer number or `nil` to use the current buffer.
function M.create_user_commands(bufnr)
  bufnr = bufnr or 0 -- `0` is an alias for current buffer number
  vim.api.nvim_buf_create_user_command(bufnr, 'AsciiDocPreviewNotify', require('asciidoc-preview').notify_server, {})
  vim.api.nvim_buf_create_user_command(bufnr, 'AsciiDocPreviewOpen', require('asciidoc-preview').open_browser, {})
  vim.api.nvim_buf_create_user_command(bufnr, 'AsciiDocPreviewStop', require('asciidoc-preview').stop_server, {})
end

---Creates the additional buffer-local user commands
---in all buffers with an AsciiDoc filetype.
function M.create_user_commands_all()
  for _, bufnr in ipairs(util.get_asciidoc_buffers()) do
    M.create_user_commands(bufnr)
  end
end

---Deletes the additional buffer-local user commands
---in all buffers with an AsciiDoc filetype.
local function delete_user_commands_all()
  for _, bufnr in ipairs(util.get_asciidoc_buffers()) do
    vim.api.nvim_buf_del_user_command(bufnr, 'AsciiDocPreviewNotify')
    vim.api.nvim_buf_del_user_command(bufnr, 'AsciiDocPreviewOpen')
    vim.api.nvim_buf_del_user_command(bufnr, 'AsciiDocPreviewStop')
  end
end

-- Sets up the plugin.
M.setup = config.setup
-- M.setup = function(opts)
--   -- print('setup: ' .. vim.inspect(opts))
--   config.setup(opts)
-- end

---Starts the server with the needed autocommand event handlers and user commands.
---When started, open the preview in the web browser or warns the user if not.
function M.start_server()
  -- Allows only buffers with an AsciiDoc filetype to start the server.
  if not util.is_asciidoc_buffer() then
    notify.warn('The preview can only be started if you are in an AsciiDoc file.')
    return
  end

  -- Creates the needed autocommand event handlers and user commands.
  create_auto_commands()
  M.create_user_commands_all()

  -- Starts the server.
  server.start()

  -- Initializes the server and opens the preview in the web browser
  -- or warns the user if the server failed to start.
  if server.is_running() then
    vim.g.tigion_asciidocPreview_isStarted = true
    server.send_options()
    M.send_file_to_server()
    M.open_browser() -- v1: here, v2: opens with node.js server
  else
    notify.warn('Preview server failed to start.', { show_check_health = true })
    M.stop_server()
  end
end

---Stops the server and deletes the autocommand event handlers and user commands.
function M.stop_server()
  vim.g.tigion_asciidocPreview_isStarted = false
  server.stop()
  clear_auto_commands()
  delete_user_commands_all()
end

---Sends a file path and the preview position to the server.
function M.send_file_to_server()
  local filepath = vim.fn.expand('%:p') -- The file in the editor with full path.
  local preview_position = -1 -- The current scroll position.
  if config.options.preview.position == config.POSITIONS.START then
    preview_position = 0 -- The start of the preview website.
  elseif config.options.preview.position == config.POSITIONS.SYNC then
    preview_position = util.get_current_line_position_in_percent() -- The same (similar) position as in Neovim.
  end
  server.send_file(filepath, preview_position)
end

---Sends a notification to the server to refresh the preview page.
function M.notify_server()
  if config.options.preview.notify == config.NOTIFIES.PAGE then
    server.send_page_notify() -- notify page
  else
    server.send_content_notify() -- notify content
  end
end

---Opens the preview in the web browser.
--
-- TODO: Check is `vim.ui.open` (Neovim 0.10+) is a better alternative.
--
-- NOTE: execute open cmd:
-- - `io.popen` and `os.execute` freezes neovim on Linux
--   - https://github.com/tigion/nvim-asciidoc-preview/issues/9
-- - `vim.fn.jobstart`: prefer `vim.system` in Lua
--
function M.open_browser()
  -- vim.ui.open(config.server.url)

  local open_cmd = util.get_open_cmd()
  if open_cmd ~= nil then
    -- io.popen(open_cmd .. ' ' .. config.server.url)
    -- os.execute(open_cmd .. ' ' .. config.server.url)
    -- vim.fn.jobstart(open_cmd .. ' ' .. config.server.url, { detach = true })
    vim.system({ open_cmd, config.server.url }, { detach = true })
  end
end

return M
