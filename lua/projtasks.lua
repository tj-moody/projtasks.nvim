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
    if not M.has_projfile and not M.config.defaults[vim.bo.filetype] then
        return function()
            vim.print("No projfile found in current project.")
        end
    end
    local tasks = M.has_projfile and M.proj_config["tasks"] or M.config.defaults[vim.bo.filetype]

    if not tasks[task_key] then
        return function()
            print("Task `" .. task_key .. "` not found.")
        end
    end
    local task = tasks[task_key]

    -- Static terminal output
    if not task.use_qflist or task.use_qflist == false then
        return function()
            vim.cmd.vsplit()
            vim.cmd.terminal("ptask " .. task_key)
            vim.cmd("setlocal nobuflisted")
        end
    end

    -- qflist output
    return function()
        local tmpfile = vim.fn.tempname()
        local efm = vim.o.errorformat

        vim.fn.jobstart(("ptask %s > %s 2>&1"):format(task_key, tmpfile), {
            on_exit = function(_, _)
                vim.schedule(function()
                    local lines = vim.fn.readfile(tmpfile)

                    vim.fn.delete(tmpfile)

                    vim.fn.setqflist({}, "r", {
                        title = "ptask " .. task_key,
                        lines = lines,
                        efm = efm,
                    })

                    if #vim.fn.getqflist() > 0 then
                        vim.cmd("copen")
                    end
                end)
            end,
        })
    end
end

return M
