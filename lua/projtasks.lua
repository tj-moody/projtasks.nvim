local M = {}

---@type ProjtasksConfig
local default_config = {
    defaults = {},
    static_config = {
        direction = "vertical",
        size = {
            vertical = 70,
            horizontal = 20,
        },
    },
    terminal_config = {
        direction = "horizontal",
        size = {
            vertical = 70,
            horizontal = 20,
        },
    },
}

M.terminal = require("projtasks.terminal")
M.static = require("projtasks.static")

M.toggle = function()
    M.terminal:toggle()
end

function M:toggle_terminal_direction()
    M.terminal:toggle_direction()
end

function M:toggle_static_direction()
    M.static:toggle_direction()
end

---@param user_config ProjtasksConfig
M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", default_config, user_config)
    M.has_projfile, M.proj_config = pcall(require, "projfile")
    M.terminal.config = M.config.terminal_config
    M.static.config = M.config.static_config
end

M.persistent_runner = function(task_key)
    return function()
        M.terminal:exec_task("ptask " .. task_key)
    end
end

M.static_runner = function(task_key)
    local tasks = M.has_projfile and M.proj_config["tasks"] or M.config.defaults[vim.bo.filetype]

    if not tasks then
        return function()
            vim.print("No projfile found in current project.")
        end
    end

    if not tasks[task_key] then
        return function()
            print("Task `" .. task_key .. "` not found.")
        end
    end
    local task = tasks[task_key]

    -- Static terminal output
    ---@diagnostic disable-next-line: undefined-field
    if not task.use_qflist then
        return function()
            M.static:exec_static("ptask " .. task_key)
        end
    end

    -- qflist output
    return function()
        M.static:exec_qflist("ptask " .. task_key)
    end
end

return M
