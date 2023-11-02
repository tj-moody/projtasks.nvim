local M = {}

---@type ProjtasksConfig
local default_config = {
    terminal_direction = "vertical",
    defaults = {},
    size = {
        vertical = 70,
        horizontal = 20,
    }
}


local enter_code = vim.api.nvim_replace_termcodes(
    "<CR>",
    false, false, true
)

M.terminal = require('projtasks.terminal')

---@param task_key "run" | "build" | "test"
---@param fallback function
---@return function
local function create_terminal_runner(task_key, fallback)
    if not task_key then return fallback end
    if not M.has_projfile and not M.terminal.config.defaults[vim.bo.filetype] then
        return fallback
    end

    local tasks = M.config.defaults[vim.bo.filetype]
    if M.has_projfile then tasks = M.proj_config["tasks"] end

    if not tasks[task_key] then
        return function() print("Task `" .. task_key .. "` not found.") end
    end
    return function()
        M.terminal:focus_term(M.config)
        vim.api.nvim_feedkeys(tasks[task_key] .. enter_code, 't', true)
        M.last_task_key = task_key
    end
end

M.toggle = function()
    M.terminal:toggle(M.config)
end

M.term_recent = create_terminal_runner(M.last_task_key, M.toggle)

M.toggle_terminal_direction = function()
    M.terminal:toggle_terminal_direction(M.config)
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

end

return M
