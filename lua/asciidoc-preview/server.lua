local config = require('asciidoc-preview.config')
local commands = require('asciidoc-preview.config').commands

local M = {}

---Executes a command if the server is running.
--
-- NOTE: execute command with:
-- - io.popen(...)
--   - can read command output
--     - local handle = io.popen(command)
--     - local read = handle:read("*a")
-- - os.execute(...)
-- - execute('! ...')
-- - vim.api.nvim_command(...)
--
---@param cmd string
---@param serverMustRun? boolean
local function execCommand(cmd, serverMustRun)
  serverMustRun = serverMustRun or true
  if M.isRunning() == serverMustRun then
    io.popen(cmd)
    -- os.execute(cmd)
  end
end

---Checks if the server is running.
---The correct server is validated with a simple Hi message.
---@return boolean?
function M.isRunning()
  local handle = io.popen(commands.getHi)
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

---Starts the server if not running.
function M.start()
  -- execCommand(command.start, false)
  if not M.isRunning() then
    -- print('AsciiDocPreview: Starting ...')
    os.execute(commands.start) -- start server
    vim.wait(5000, M.isRunning) -- Give server some time to start

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
function M.stop()
  execCommand(commands.postStop)
end

---Sends the options to the server.
function M.sendOptions()
  local converter = config.options.server.converter
  local json = '\'{ "options": { "converter": "' .. converter .. '" } }\''
  local cmd = commands.putOptions .. ' -H "Content-Type: application/json"' .. ' -d ' .. json
  execCommand(cmd)
end

---Sends the filepath and position to the server.
---@param filepath string Filename with the full path
---@param position? integer Scroll position for the preview
function M.sendFile(filepath, position)
  position = position or -1
  local json = '\'{ "preview": { "filepath": "' .. filepath .. '", "position": ' .. position .. " } }'"
  local cmd = commands.putFile .. ' -H "Content-Type: application/json"' .. ' -d ' .. json
  execCommand(cmd)
end

---Sends a notification to the server to initiate
---a reload of the preview website.
function M.sendPageNotify()
  execCommand(commands.postNotifyPage)
end

---Sends a notification to the server to initiate
---a reload the content of the preview website.
function M.sendContentNotify()
  execCommand(commands.postNotifyContent)
end

return M
