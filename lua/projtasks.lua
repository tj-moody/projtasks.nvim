local M = {}

local default_config = {
    terminal_direction = "vertical"
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
    vim.cmd("bprev")
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
M.toggle_term = function()
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
local function create_command(name, task_key, desc)
    vim.api.nvim_create_user_command(name,
        function()
            focus_term()
            vim.api.nvim_feedkeys(proj_config["tasks"][task_key] .. enter_code, 't', true)
        end,
        { desc = desc }
    )
end

M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", default_config, user_config)
    ok, proj_config = pcall(require, 'projfile')
    vim.api.nvim_create_user_command(
        "ProjtasksToggle",
        function()
            M.toggle_term()
        end,
        { desc = "Toggle Projtasks Terminal" }
    )
    if not ok then
        vim.api.nvim_create_user_command("ProjtasksRun",
            function() print("No projfile in current project") end, { desc = "Run Project" })
        vim.api.nvim_create_user_command("ProjtasksTest",
            function() print("No projfile in current project") end, { desc = "Test Project" })
    else
        create_command("ProjtasksRun", "run", "Run  Project")
        create_command("ProjtasksTest", "test", "Test Project")
        create_command("ProjtasksBuild", "build", "Run  Project")
    end
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
        M.toggle_term()
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

return M
