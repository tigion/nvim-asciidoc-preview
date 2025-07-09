local config = require('asciidoc-preview.config')
local notify = require('asciidoc-preview.notify')
local commands = require('asciidoc-preview.config').commands

---@class asciidoc-preview.server
local M = {}

---Executes a command depending on whether the server is running or not.
--
-- NOTE: execute command with:
-- - io.popen(...)
--   - can read command output
--     - local handle = io.popen(command)
--     - local read = handle:read("*a")
-- - os.execute(...)
-- - execute('! ...')
-- - vim.api.nvim_command(...)
-- - vim.fn.jobstart(...) -> prefer vim.system() in Lua
-- - vim.system(...)
--
---@param cmd string The command to execute.
---@param server_must_run? boolean Whether the server must be running.
local function exec_command(cmd, server_must_run)
  server_must_run = server_must_run or true
  if M.is_running() == server_must_run then
    io.popen(cmd)
    -- os.execute(cmd)
    -- vim.system({ ... }, { detach = true }) -- needs separated arguments ('curl -s ...' -> { 'curl', '-s', ... })
  end
end

---Checks if the server is running.
---The correct server is validated with a simple Hi message.
---@return boolean?
function M.is_running()
  local handle = io.popen(commands.get_hi)
  if handle then
    local read = handle:read('*a')
    if read and read ~= '' and vim.json.decode(read)['hi'] == config.server.hi then
      return true
    else
      return false
    end
  end
  return nil
end

---Starts the server if it is not running.
function M.start()
  -- exec_command(command.start, false)
  if M.is_running() then
    notify.info('The preview server is already running.')
  else
    -- print('AsciiDocPreview: Starting ...')
    os.execute(commands.start) -- start server
    vim.wait(5000, M.is_running) -- Give server some time to start

    -- NOTE: With `io.popen()` nvim hangs sometimes
    --
    -- local handle = io.popen(command.start)
    -- if handle then
    --   -- read first output line => server is started
    --   local read = handle:read '*l'
    --   -- print(read)
    -- end
  end
end

---Stops the server.
function M.stop() exec_command(commands.post_stop) end

---Sends the options to the server.
function M.send_options()
  local converter = config.options.server.converter
  local json = '\'{ "options": { "converter": "' .. converter .. '" } }\''
  local cmd = commands.put_options .. ' -H "Content-Type: application/json"' .. ' -d ' .. json
  exec_command(cmd)
end

---Sends the filepath and position to the server.
---@param filepath string The filename with the full path.
---@param position? integer The scroll position for the preview.
function M.send_file(filepath, position)
  position = position or -1
  local json = '\'{ "preview": { "filepath": "' .. filepath .. '", "position": ' .. position .. " } }'"
  local cmd = commands.put_file .. ' -H "Content-Type: application/json"' .. ' -d ' .. json
  exec_command(cmd)
end

---Sends a notification to the server to initiate
---a reload of the preview website.
function M.send_page_notify() exec_command(commands.post_notify_page) end

---Sends a notification to the server to initiate
---a reload of the content of the preview website.
function M.send_content_notify() exec_command(commands.post_notify_body) end

return M
