---@class ProjtasksWezterm
local Wezterm = {}
local wezterm = require('wezterm')

---@param projtasks_config? ProjtasksConfig
function Wezterm:create(projtasks_config)
    local config = {}
    if not projtasks_config then
        config = self.config
    else
        config = projtasks_config.terminal_config
        self.config = config
    end

    local prev_pane_ids = {}
    for _, pane in ipairs(wezterm.list_panes()) do
        prev_pane_ids[#prev_pane_ids+1] = pane.pane_id
    end

    -- FIX: split_pane functions don't work, issue filed
    --      https://github.com/willothy/wezterm.nvim/issues/9

    -- if config.terminal_direction == "vertical" then
    --     wezterm.split_pane.vertical()
    -- elseif config.terminal_direction == "horizontal" then
    --     wezterm.split_pane.horizontal()
    -- else
    --     print("Invalid terminal direction")
    -- end

    local pane_id = nil
    for _, pane in ipairs(wezterm.list_panes()) do
        local is_new_pane = true
        for _, prev_pane_id in ipairs(prev_pane_ids) do
            if prev_pane_id == pane.pane_id then
                is_new_pane = false
            end
        end
        if is_new_pane then
            pane_id = pane.pane_id
        end
    end

    if pane_id then
        self.pane_id = pane_id
    else
        print("ERROR CREATING PANE")
    end
end

---@return boolean
function Wezterm:is_visible()
    for _, pane in ipairs(wezterm.list_panes()) do
        if pane.pane_id == self.pane_id then
            return true
        end
    end
    return false
end

---@return boolean
function Wezterm:exists()
    for _, pane in ipairs(wezterm.list_panes()) do
        if pane.pane_id == self.pane_id then
            return pane.is_active
        end
    end
    return false
end

---@param projtasks_config ProjtasksConfig
function Wezterm:open_term(projtasks_config)
    if not self.pane_id or not self:exists() then
        self:create(projtasks_config)
    else
        wezterm.switch_pane.id(self.pane_id)
    end
end

function Wezterm:close_term()
    wezterm.switch_pane.id(self.pane_id)
    wezterm.spawn("exit", {})
end

---@param config ProjtasksConfig
function Wezterm:toggle(config)
    if self:is_visible() then
        self:close_term()
    else
        self:open_term(config)
    end
end

function Wezterm:focus_term(projtasks_config)
    if self:is_visible() then
        self:close_term()
    else
        self:open_term(projtasks_config)
    end
end

function Wezterm:exec_task(projtasks_config, task_cmd)
    self:focus_term(projtasks_config)
    -- TODO: Format `task_cmd` as list of cmd/args

    -- wezterm.spawn(task_cmd, {
    --     pane = self.pane_id,
    --     new_window = false,
    -- })
end

return Wezterm
