local M = {}

---@type ProjtasksConfig
local default_config = {
    defaults = {},
    output = "terminal",
    terminal_config = {
        terminal_direction = "vertical",
        size = {
            vertical = 70,
            horizontal = 20,
        }
    }
}


M.terminal = require('projtasks.terminal')
M.file = require('projtasks.file')

---@param task_key "run" | "build" | "test" | "bench" | "profile"
---@param fallback function
---@return function
local function create_terminal_runner(task_key, fallback)
    if not task_key then return fallback end
    if not M.has_projfile and not M.config.defaults[vim.bo.filetype] then
        return fallback
    end

    local tasks = M.config.defaults[vim.bo.filetype]
    if M.has_projfile then tasks = M.proj_config["tasks"] end
    if M.has_projfile then version = M.proj_config["version"] end

    if not tasks[task_key] then
        return function() print("Task `" .. task_key .. "` not found.") end
    end
    return function()
        M.last_task_key = task_key
        local task_cmds = tasks[task_key]

        if M.config.output == "terminal" then
            M.terminal:exec_task(M.config, task_cmds, version)
        elseif M.config.output == "file" then
            M.file:exec_task(M.config, task_cmds, version)
        end
    end
end

M.toggle = function()
    M.terminal:toggle(M.config)
end

-- Currently does not work: needs to update last task every time a task is run
-- M.term_recent = create_terminal_runner(M.last_task_key, M.toggle)

M.toggle_terminal_direction = function()
    if M.config.output == "terminal" then
        M.terminal:toggle_terminal_direction(M.config)
    end
end

---@param user_config ProjtasksConfig
M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", default_config, user_config)
    M.has_projfile, M.proj_config = pcall(require, 'projfile')

    local missing_projfile_fallback = function()
        print("No projfile in current project")
    end
    M.term_run = create_terminal_runner("run", missing_projfile_fallback)
    M.term_build = create_terminal_runner("build", missing_projfile_fallback)
    M.term_test = create_terminal_runner("test", missing_projfile_fallback)
    M.term_bench = create_terminal_runner("bench", missing_projfile_fallback)
    M.term_profile = create_terminal_runner("profile", missing_projfile_fallback)
    M.file:create_resize_autocmd()
end

M.change_output = function()
    vim.ui.select({ 'terminal', 'file' }, {
        prompt = 'Choose output method:',
    }, function(choice)
        M.config.output = choice
    end)
end

return M
