---@class ProjtasksFile
local File = {}
File.last_buf = nil

local function split(str, sep)
   local result = {}
   local regex = ("([^%s]+)"):format(sep)
   for each in str:gmatch(regex) do
      table.insert(result, each)
   end
   return result
end

function File:create_resize_autocmd()
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

function File:exec_task(projtasks_config, task_cmd)
    self.config = projtasks_config.terminal_config
    jobs_list = split(task_cmd, ';')
    for i, job in ipairs(jobs_list) do
        jobs_list[i] = split(job, ' ')
    end

    self.bufnr = vim.api.nvim_create_buf(false, true)

    if self.last_buf then
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_buf(win) == self.last_buf then
                vim.api.nvim_win_close(win, false)
                vim.cmd.bdelete(self.last_buf)
                P("closing " .. self.last_buf)
            end
        end
    end
    self.last_buf = self.bufnr

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

    vim.cmd.b(self.bufnr)

    for _, job in ipairs(jobs_list) do
        vim.fn.jobstart(job, {
            stdout_buffered = true,
            on_stdout = function(_, data)
                if data then
                    vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, false, data)
                end
            end
        })
    end
end

return File
