local M = {}

---@type ProjtasksConfig
local default_config = {
    terminal_direction = "vertical",
    defaults = {},
}

M.config = default_config

local create_term = function()
    M.bufnr = vim.api.nvim_create_buf(false, false) + 1
    vim.cmd("terminal")
    vim.cmd("setlocal nonumber norelativenumber nobuflisted")
    vim.cmd("setlocal filetype=projterm")
    vim.api.nvim_buf_set_keymap(
        M.bufnr,
        "n", "q", "<cmd>close<CR>",
        { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        M.bufnr,
        "t", "<C-T>", "<cmd>close<CR>",
        { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        M.bufnr,
        "n", "<C-T>", "<cmd>close<CR>",
        { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        M.bufnr,
        "n", "p", "",
        { noremap = true, silent = true }
    )
    if #vim.fn.getbufinfo({ buflisted = 1 }) > 1 then
        vim.cmd("bprev")
    end
end

local enter_code = vim.api.nvim_replace_termcodes(
    "<CR>",
    false, false, true
)


local is_visible = function()
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local winbufnr = vim.api.nvim_win_get_buf(winid)
        local winvalid = vim.api.nvim_win_is_valid(winid)

        if winvalid and winbufnr == M.bufnr then
            return true
        end
    end

    return false
end


local function open_term()
    if M.config.terminal_direction == "vertical" then
        vim.cmd.vsplit()
        vim.cmd("wincmd L")
        vim.cmd("vertical resize 70")
    elseif M.config.terminal_direction == "horizontal" then
        vim.cmd.split()
        vim.cmd("wincmd J")
        vim.cmd("horizontal resize 20")
    else
        print("Invalid `terminal_direction`")
    end
    if not M.bufnr or not vim.api.nvim_buf_is_valid(M.bufnr) then
        create_term()
    end
    vim.cmd.b(M.bufnr)
    vim.cmd("startinsert!")
end

local function close_term()
    vim.cmd("close " .. vim.fn.bufwinnr(M.bufnr))
end

M.toggle = function()
    if is_visible() then
        close_term()
    else
        open_term()
    end
end

local function focus_term()
    if is_visible() then
        close_term()
    end
    open_term()
end

---@param task_key "run" | "build" | "test"
---@param fallback function
---@return function
local function create_task_runner(task_key, fallback)
    if not task_key then return fallback end
    if not M.has_projfile and not M.config.defaults[vim.bo.filetype] then
        return fallback
    end

    local tasks = M.config.defaults[vim.bo.filetype]
    if M.has_projfile then
        tasks = M.proj_config["tasks"]
    end

    if not tasks[task_key] then
        return function() print("Task " .. task_key .. " not found.") end
    end
    return function()
        focus_term()
        vim.api.nvim_feedkeys(tasks[task_key] .. enter_code, 't', true)
        M.last_task_key = task_key
    end
end

M.recent = create_task_runner(M.last_task_key, M.toggle)

---@param user_config ProjtasksConfig
M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", default_config, user_config)
    M.has_projfile, M.proj_config = pcall(require, 'projfile')

    local missing_projfile_fallback = function()
        print("No projfile in current project")
    end
    M.run = create_task_runner("run", missing_projfile_fallback)
    M.build = create_task_runner("build", missing_projfile_fallback)
    M.test = create_task_runner("test", missing_projfile_fallback)
end

M.toggle_terminal_direction = function()
    if M.config.terminal_direction == "horizontal" then
        M.config.terminal_direction = "vertical"
    elseif M.config.terminal_direction == "vertical" then
        M.config.terminal_direction = "horizontal"
    else
        print("Invalid `terminal_direction`")
    end
    if is_visible() then
        M.toggle()
        open_term()
    end
end

-- TODO: Add neotest integration
-- TODO: Add godbolt integration
-- TODO: Add defaults based on project type and
--       structure, ie `cargo run`, `cargo test`,
--       etc. by default in Rust projects.
-- TODO: Output to file instead
--       of terminal window?
-- TODO: Export function to run most recent command

return M
