---@class ProjtasksTerminal
local Terminal = {}

local enter_code = vim.api.nvim_replace_termcodes(
    "<CR>",
    false, false, true
)

function Terminal:create_resize_autocmd()
    vim.api.nvim_create_autocmd("WinResized", {
        pattern = '*',
        group = vim.api.nvim_create_augroup("Projtasks", {}),
        callback = function()
            event = vim.v.event
            if not event.windows then return end
            for _, win in ipairs(event.windows) do
                if vim.api.nvim_win_get_buf(win) == self.bufnr then
                    if self.config.terminal_direction == "vertical" then
                        self.config.size.vertical = vim.api.nvim_win_get_width(win)
                    else
                        self.config.size.horizontal = vim.api.nvim_win_get_height(win)
                    end
                end
            end
        end
    })
end

---@param projtasks_config? ProjtasksConfig
function Terminal:init(projtasks_config)
    local config = {}
    if not projtasks_config then
        config = self.config
    else
        config = projtasks_config.terminal_config
        self.config = config
    end

    local bufnr = vim.api.nvim_create_buf(false, false) + 1
    vim.cmd("terminal")
    vim.cmd("setlocal nonumber norelativenumber nobuflisted")
    vim.cmd("setlocal filetype=projterm")

    -- From toggleterm docs
    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('t', '<C-t>', [[<Cmd>close<CR>]], opts)
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
    vim.keymap.set('n', '<CR>',  [[i<CR>]], opts)

    if #vim.fn.getbufinfo({ buflisted = 1 }) > 1 then
        vim.cmd("bprev")
    end

    self.bufnr = bufnr
end

---@return boolean
function Terminal:is_visible()
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local winbufnr = vim.api.nvim_win_get_buf(winid)
        local winvalid = vim.api.nvim_win_is_valid(winid)

        if winvalid and winbufnr == self.bufnr then
            return true
        end
    end

    return false
end

---@param projtasks_config ProjtasksConfig
function Terminal:open_term(projtasks_config)
    if not self.config then self.config = projtasks_config.terminal_config end
    if self.config.terminal_direction == "vertical" then
        vim.cmd.vsplit()
        vim.cmd("wincmd L")
        vim.cmd("vertical resize " .. self.config.size.vertical)
    elseif self.config.terminal_direction == "horizontal" then
        vim.cmd.split()
        vim.cmd("wincmd J")
        vim.cmd("horizontal resize " .. self.config.size.horizontal)
    else
        print("Invalid `terminal_direction`")
    end
    if not self.bufnr or not vim.api.nvim_buf_is_valid(self.bufnr) then
        self:init(projtasks_config)
        self:create_resize_autocmd()
    end
    vim.cmd.b(self.bufnr)
    vim.cmd("startinsert!")
end

function Terminal:close_term()
    vim.cmd("close " .. vim.fn.bufwinnr(self.bufnr))
end

---@param config ProjtasksConfig
function Terminal:focus_term(config)
    if self:is_visible() then
        self:close_term()
    end
    self:open_term(config)
end

---@param projtasks_config ProjtasksConfig
function Terminal:toggle(projtasks_config)
    if self:is_visible() then
        self:close_term()
    else
        self:open_term(projtasks_config)
    end
end

---@param projtasks_config ProjtasksConfig
function Terminal:toggle_terminal_direction(projtasks_config)
    if self.config.terminal_direction == "horizontal" then
        self.config.terminal_direction = "vertical"
    elseif self.config.terminal_direction == "vertical" then
        self.config.terminal_direction = "horizontal"
    else
        print("Invalid `terminal_direction`")
    end
    if self:is_visible() then
        self:toggle(projtasks_config)
        self:open_term(projtasks_config)
    end
end

---@param projtasks_config ProjtasksConfig
---@param task_cmds string[] | string
---@param version string
function Terminal:exec_task(projtasks_config, task_cmds, version)
    self:focus_term(projtasks_config)
    if version == "0.1.0" then
        vim.api.nvim_feedkeys(task_cmds .. enter_code, 't', true)
    elseif version == "0.1.1" then
        for _, cmd in ipairs(task_cmds) do ---@diagnostic disable-line
            vim.api.nvim_feedkeys(cmd .. enter_code, 't', true)
        end
    end
end


return Terminal
