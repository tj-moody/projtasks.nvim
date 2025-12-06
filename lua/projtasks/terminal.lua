---@class ProjtasksTerminal
local Terminal = {}

-- Persist terminal size after closing
function Terminal:create_resize_autocmd()
    vim.api.nvim_create_autocmd("WinResized", {
        pattern = "*",
        group = vim.api.nvim_create_augroup("ProjTerm", { clear = true }),
        callback = function()
            local event = vim.v.event
            if not event.windows then
                return
            end
            for _, win in ipairs(event.windows) do
                if vim.api.nvim_win_get_buf(win) == self.bufnr then
                    if self.config.direction == "vertical" then
                        self.config.size.vertical = vim.api.nvim_win_get_width(win)
                    else
                        self.config.size.horizontal = vim.api.nvim_win_get_height(win)
                    end
                end
            end
        end,
    })
end

function Terminal:initialized()
    if self.config then
        return true
    end
    return false
end

function Terminal:buf_valid()
    return self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr)
end

function Terminal:init()
    open_window(self.config)

    vim.cmd("terminal")
    print("OPENING")
    local bufnr = vim.api.nvim_get_current_buf()
    vim.cmd("setlocal nonumber norelativenumber nobuflisted")
    vim.cmd("setlocal filetype=projterm")

    -- From toggleterm docs
    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("t", "<C-t>", [[<Cmd>close<CR>]], opts)
    vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
    vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
    vim.keymap.set("n", "<CR>", [[i<CR>]], opts)

    self.bufnr = bufnr
    self.channel = vim.bo[bufnr].channel
    self:create_resize_autocmd()
end

---@return boolean
function Terminal:is_visible()
    if not self:buf_valid() or not self:initialized() then
        return false
    end
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local winbufnr = vim.api.nvim_win_get_buf(winid)
        local winvalid = vim.api.nvim_win_is_valid(winid)

        if winvalid and winbufnr == self.bufnr then
            return true
        end
    end

    return false
end

function open_window(config)
    if config.direction == "vertical" then
        vim.cmd.vsplit()
        vim.cmd("wincmd L")
        vim.cmd("vertical resize " .. config.size.vertical)
    elseif config.direction == "horizontal" then
        vim.cmd.split()
        vim.cmd("wincmd J")
        vim.cmd("horizontal resize " .. config.size.horizontal)
    else
        print("Invalid `terminal_direction`")
    end
end

function Terminal:open_term()
    if not self:buf_valid() then
        self:init()
    else
        open_window(self.config)
        vim.cmd.b(self.bufnr)
    end
    vim.cmd("startinsert!")
end

function Terminal:close_term()
    vim.cmd("close " .. vim.fn.bufwinnr(self.bufnr))
end

function Terminal:focus_term()
    if self:is_visible() then
        self:close_term()
    end
    self:open_term()
end

function Terminal:toggle()
    if self:is_visible() then
        self:close_term()
    else
        self:open_term()
    end
end

function Terminal:toggle_direction()
    if self.config.direction == "horizontal" then
        self.config.direction = "vertical"
    elseif self.config.direction == "vertical" then
        self.config.direction = "horizontal"
    else
        print("Invalid `terminal_direction`")
    end
    if self:is_visible() then
        self:close_term()
        self:open_term()
    end
end

---@param task_cmd string
function Terminal:exec_task(task_cmd)
    self:focus_term()
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.api.nvim_chan_send(self.channel, task_cmd .. "\r")
end

return Terminal
