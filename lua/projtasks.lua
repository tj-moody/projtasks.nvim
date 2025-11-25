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

M.toggle_terminal_direction = function()
    M.terminal:toggle_terminal_direction(M.config)
end

---@param user_config ProjtasksConfig
M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", default_config, user_config)
    M.has_projfile, M.proj_config = pcall(require, "projfile")
end

M.live_runner = function(task_key)
    return function()
        M.terminal:exec_task(M.config, "ptask " .. task_key, "0.1.0")
    end
end

M.static_runner = function(task_key)
    return function()
        vim.cmd.vsplit()
        vim.cmd.terminal("ptask " .. task_key)
        vim.cmd("setlocal nobuflisted")
    end
end

return M
