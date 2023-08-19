local M = {}

local new_vert_term = function()
    local buf = vim.api.nvim_create_buf(false, false) + 1
    vim.cmd("terminal")
    vim.cmd("setlocal nonumber norelativenumber nobuflisted")
    vim.cmd("setlocal filetype=projterm")
    vim.api.nvim_buf_set_keymap(
        buf,
        "n", "q", "<cmd>close<CR>",
        { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        buf,
        "t", "<C-T>", "<cmd>close<CR>",
        { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        buf,
        "n", "<C-T>", "<cmd>close<CR>",
        { noremap = true, silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        buf,
        "n", "p", "",
        { noremap = true, silent = true }
    )
    vim.cmd("bprev")

    return buf
end

local enter_code = vim.api.nvim_replace_termcodes(
    "<CR>",
    false, false, true
)


local is_visible = function(bufnr)
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local winbufnr = vim.api.nvim_win_get_buf(winid)
        local winvalid = vim.api.nvim_win_is_valid(winid)

        if winvalid and winbufnr == bufnr then
            return true
        end
    end

    return false
end

M.setup = function()
    ok, proj_config = pcall(require, 'projfile')
    if not ok then
        vim.api.nvim_create_user_command(
            "ProjtasksToggle",
            function()
                print("No projfile in current project")
            end,
            { desc = "Toggle Projtasks Terminal" }
        )

        vim.api.nvim_create_user_command(
            "ProjtasksRun",
            function()
                print("No projfile in current project")
            end,
            { desc = "Run Project" }
        )
        return
    end

    vim.api.nvim_create_user_command(
        "ProjtasksToggle",
        function()
            if not bufnr then
                vim.cmd.vsplit()
                vim.cmd("vertical resize 70")
                bufnr = new_vert_term()
                vim.cmd.b(bufnr)
                vim.cmd("startinsert!")
            elseif is_visible(bufnr) then
                vim.cmd("close " .. vim.fn.bufwinnr(bufnr))
            else
                vim.cmd.vsplit()
                vim.cmd("vertical resize 70")
                if not vim.api.nvim_buf_is_valid(bufnr) then
                    bufnr = new_vert_term()
                end
                vim.cmd.b(bufnr)
                vim.cmd("startinsert!")
            end
        end,
        { desc = "Toggle Projtasks Terminal" }
    )

    vim.api.nvim_create_user_command(
        "ProjtasksRun",
        function()
            if not bufnr then
                vim.cmd("ProjtasksToggle")
                vim.cmd("ProjtasksToggle")
            end
            if not is_visible(bufnr) then
                vim.cmd.vsplit()
                vim.cmd("vertical resize 70")
                if not vim.api.nvim_buf_is_valid(bufnr) then
                    bufnr = new_vert_term()
                end
                vim.cmd.b(bufnr)
                vim.cmd("startinsert!")
            else
                vim.cmd("ProjtasksToggle")
                vim.cmd("ProjtasksToggle")
            end
            vim.api.nvim_feedkeys(proj_config["tasks"]["run"] .. enter_code, 't', true)
        end,
        { desc = "Run Project" }
    )

    vim.api.nvim_create_user_command(
        "ProjtasksTest",
        function()
            if not bufnr then
                vim.cmd("ProjtasksToggle")
                vim.cmd("ProjtasksToggle")
            end
            if not is_visible(bufnr) then
                vim.cmd.vsplit()
                vim.cmd("vertical resize 70")
                if not vim.api.nvim_buf_is_valid(bufnr) then
                    bufnr = new_vert_term()
                end
                vim.cmd.b(bufnr)
                vim.cmd("startinsert!")
            else
                vim.cmd("ProjtasksToggle")
                vim.cmd("ProjtasksToggle")
            end
            vim.api.nvim_feedkeys(proj_config["tasks"]["test"] .. enter_code, 't', true)
        end,
        { desc = "Test Project" }
    )
end

-- TODO: Add neotest integration
-- TODO: Add godbolt integration
-- TODO: Add defaults based on project type and
--       structure, ie `cargo run`, `cargo test`,
--       etc. by default in Rust projects.
-- TODO: Output to file instead
--       of terminal window?

return M
