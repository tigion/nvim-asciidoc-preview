-- server.lua

--[[
TODO: execute command with:
- io.popen(...)
  - can read command output
    - local handle = io.popen(command)
    - local read = handle:read("*a")
- os.execute(...)
- execute('! ...')
- vim.api.nvim_command(...)
]]
--

local config = require 'asciidoc-preview.config'

local M = {}

local apiURLs = {
  hi = config.server.url .. '/api/hi',
  file = config.server.url .. '/api/file',
  actions = {
    notify = {
      page = config.server.url .. '/api/actions/notify?type=page',
      content = config.server.url .. '/api/actions/notify?type=content',
    },
    stop = config.server.url .. '/api/actions/stop',
  },
}

local command = {
  start = config.server.start,
  postStop = 'curl -s -X POST ' .. apiURLs.actions.stop,
  getHi = 'curl -s -X GET ' .. apiURLs.hi,
  putFile = 'curl -s -X PUT ' .. apiURLs.file,
  postNotifyPage = 'curl -s -X POST ' .. apiURLs.actions.notify.page,
  postNotifyContent = 'curl -s -X POST ' .. apiURLs.actions.notify.content,
}

local function execCommand(cmd, serverMustRun)
  serverMustRun = serverMustRun or true
  if M.isRunning() == serverMustRun then
    io.popen(cmd)
    --os.execute(cmd)
  end
end

-- check if server is running and answers with the correct hi message
function M.isRunning()
  local handle = io.popen(command.getHi)
  if handle then
    local read = handle:read '*a'
    if read and read ~= '' and vim.json.decode(read).hi == config.server.hi then
      return true
    else
      return false
    end
  end
  return nil
end

-- start needed Node.ja server
function M.start()
  --execCommand(command.start, false)
  if not M.isRunning() then
    os.execute(command.start) -- start server
    vim.wait(5000, M.isRunning) -- give server some time to start

    -- with io.popen() nvim hangs sometimes
    --[[local handle = io.popen(command.start)
    if handle then
      -- read first output line => server is started
      local read = handle:read '*l'
      --print(read)
    end]]
    --
  end
end

-- stop server
function M.stop() execCommand(command.postStop) end

-- send file to server
function M.sendFile(path, position)
  position = position or 0
  local json = '\'{ "file": { "path": "' .. path .. '", "position": ' .. position .. ' } }\''
  local cmd = command.putFile .. ' -H "Content-Type: application/json"' .. ' -d ' .. json
  execCommand(cmd)
end

-- send notify to server (page)
function M.sendPageNotify() execCommand(command.postNotifyPage) end

-- send notify to server (content)
function M.sendContentNotify() execCommand(command.postNotifyContent) end

return M
