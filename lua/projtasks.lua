local M = {}

---@type ProjtasksConfig
local default_config = {
    defaults = {},
    terminal_config = {
        terminal_direction = "horizontal",
        size = {
            vertical = 70,
            horizontal = 20,
        },
    },
}

M.terminal = require("projtasks.terminal")

M.toggle = function()
    M.terminal:toggle(M.config)
end

-- Currently does not work: needs to update last task every time a task is run
-- M.term_recent = create_terminal_runner(M.last_task_key, M.toggle)

M.toggle_terminal_direction = function()
    M.terminal:toggle_terminal_direction(M.config)
end

---@param user_config ProjtasksConfig
M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", default_config, user_config)
    M.has_projfile, M.proj_config = pcall(require, "projfile")
end

M.create_ptask_runner = function(task_key)
    return function()
        M.terminal:exec_task(M.config, "ptask " .. task_key, "0.1.0")
    end
end

return M
