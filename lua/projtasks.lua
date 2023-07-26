local Terminal = require('toggleterm.terminal').Terminal
local M = {}

local default_conf = {
    direction = "float",
}

M.setup = function(args)
    ok, proj_config = pcall(require, 'projfile')
    if not ok then return end

    local conf = args or default_conf
    local term = Terminal:new({
        hidden = true,
        dir = "git_dir",
        direction = conf.direction,

        on_open = function(term)
            vim.cmd("startinsert!")
            vim.api.nvim_buf_set_keymap(
                term.bufnr,
                "n", "q", "<cmd>close<CR>",
                { noremap = true, silent = true }
            )
            vim.api.nvim_buf_set_keymap(
                term.bufnr,
                "t", "<C-T>", "<cmd>close<CR>",
                { noremap = true, silent = true }
            )
            vim.api.nvim_buf_set_keymap(
                term.bufnr,
                "n", "<C-T>", "<cmd>close<CR>",
                { noremap = true, silent = true }
            )
        end,

        -- on_close = function(term)
        --     vim.cmd("startinsert!")
        -- end,
    })

    vim.api.nvim_create_user_command(
        "ProjtasksToggle",
        function()
            term:toggle()
        end,
        { desc = "Toggle Projtasks Terminal" }
    )

    vim.api.nvim_create_user_command(
        "ProjtasksRun",
        function()
            term:open()
            term:send(proj_config["tasks"]["run"], false)
        end,
        { desc = "Run Project" }
    )

    vim.api.nvim_create_user_command(
        "ProjtasksTest",
        function()
            term:open()
            term:send(proj_config["tasks"]["test"], false)
        end,
        { desc = "Test Project" }
    )
end

-- TODO: Add neotest integration
-- TODO: Add godbolt integration
-- TODO: Add defaults based on project type and
--       structure, ie `cargo run`, `cargo test`,
--       etc. by default in Rust projects.

return M
