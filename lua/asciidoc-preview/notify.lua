---@class asciidoc-preview.notify
local M = {}

local default_messages = {
  check_health = 'Run `:checkhealth asciidoc-preview` to check the health of the plugin.',
}

---@class asciidoc-preview.NotifyOpts
---@field show_check_health? boolean

---Displays a notification to the user.
---@param message string -- The message to display.
---@param level? vim.log.levels -- The vim.log.levels
---@param opts? asciidoc-preview.NotifyOpts -- The options for the notification.
local function notify(message, level, opts)
  level = level or vim.log.levels.INFO
  opts = opts or {}

  -- Adds the check health message if the option is set.
  if opts.show_check_health == true then message = message .. '\n' .. default_messages.check_health end

  vim.notify(message, level, { title = 'nvim-asciidoc-preview' })
end

---Displays a info notification.
---@param message string
---@param opts? table -- The options for the notification.
function M.info(message, opts) notify(message, vim.log.levels.INFO, opts) end

---Displays a warning notification.
---@param message string
---@param opts? table -- The options for the notification.
function M.warn(message, opts) notify(message, vim.log.levels.WARN, opts) end

---Displays a error notification.
---@param message string
---@param opts? table -- The options for the notification.
function M.error(message, opts) notify(message, vim.log.levels.ERROR, opts) end

return M
