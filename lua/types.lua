---@alias projtasks { [string]: { build: string, run: string, test: string} }

---@class TerminalConfig
---@field terminal_direction? "vertical" | "horizontal"
---@field size? { vertical: integer, horizontal: integer }

---@class ProjtasksConfig
---@field defaults? projtasks
---@field terminal_config TerminalConfig
---@field output? "terminal" | "file" | "wezterm"

---@class ProjtasksTerminal
---@field bufnr integer
---@field config TerminalConfig

---@class ProjtasksWezterm
---@field pane_id integer
---@field config TerminalConfig
