local Static = {}

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

function Static:exec_static(cmd)
    open_window(self.config)
    vim.cmd.terminal(cmd)
    vim.cmd("setlocal nobuflisted")
end

function Static:exec_qflist(cmd)
    local tmpfile = vim.fn.tempname()
    local efm = vim.o.errorformat

    vim.fn.jobstart(("%s > %s 2>&1"):format(cmd, tmpfile), {
        on_exit = function(_, _)
            vim.schedule(function()
                local lines = vim.fn.readfile(tmpfile)

                vim.fn.delete(tmpfile)

                vim.fn.setqflist({}, "r", {
                    title = cmd,
                    lines = lines,
                    efm = efm,
                })

                if #vim.fn.getqflist() > 0 then
                    vim.cmd.copen()
                    vim.cmd.resize(20)
                end
            end)
        end,
    })
end

function Static:toggle_direction()
    if self.config.direction == "horizontal" then
        self.config.direction = "vertical"
    elseif self.config.direction == "vertical" then
        self.config.direction = "horizontal"
    else
        print("Invalid `terminal_direction`")
    end
end

return Static
