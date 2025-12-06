---@alias projtasks { [string]: { cmd: string } }

---@class TerminalConfig
---@field direction? "vertical" | "horizontal"
---@field size? { vertical: integer, horizontal: integer }

---@class StaticConfig
---@field direction? "vertical" | "horizontal"
---@field size? { vertical: integer, horizontal: integer }

---@class ProjtasksConfig
---@field defaults? projtasks
---@field terminal_config TerminalConfig
---@field static_config StaticConfig

---@class ProjtasksTerminal
---@field bufnr integer
---@field channel integer
---@field config TerminalConfig

---@class ProjtasksWezterm
---@field pane_id integer
---@field config TerminalConfig
