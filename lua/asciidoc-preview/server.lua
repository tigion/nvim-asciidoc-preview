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

local M = {}

local path = vim.g.tigion_asciidocPreview_rootDir

local apiURL = {
  hi = 'http://localhost:11235/api/hi',
  file = 'http://localhost:11235/api/file',
  action = {
    notifyPage = 'http://localhost:11235/api/actions/notify?type=page', -- TODO: Node.js API
    notifyContent = 'http://localhost:11235/api/actions/notify?type=content', -- TODO: Node.js API
    stop = 'http://localhost:11235/api/actions/stop',
  },
}

local command = {
  start = path .. '/server/scripts/start.sh',
  stop = 'curl -s -X POST ' .. apiURL.action.stop,
  hi = 'curl -s -X GET ' .. apiURL.hi,
  putFile = 'curl -s -X PUT ' .. apiURL.file,
  notifyPage = 'curl -s -X POST ' .. apiURL.action.notifyPage,
  notifyContent = 'curl -s -X POST ' .. apiURL.action.notifyContent,
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
  local handle = io.popen(command.hi)
  if handle then
    local read = handle:read '*a'
    if read and read ~= '' and vim.json.decode(read).hi == 'Coffee please' then
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
function M.stop() execCommand(command.stop) end

-- send file to server
function M.sendFile(file)
  local json = '\'{ "file": "' .. file .. '" }\''
  local cmd = command.putFile .. ' -H "Content-Type: application/json"' .. ' -d ' .. json
  execCommand(cmd)
end

-- send notify to server (page)
function M.sendPageNotify() execCommand(command.notifyPage) end

-- send notify to server (content)
function M.sendContentNotify() execCommand(command.notifyContent) end

return M
