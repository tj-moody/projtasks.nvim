---@alias projtasks { [string]: { build: string, run: string, test: string} }

---@class ProjtasksConfig
---@field terminal_direction? "vertical" | "horizontal"
---@field defaults? projtasks
---@field size? { vertical: integer, horizontal: integer }

---@class ProjtasksTerminal
---@field bufnr integer
---@field config ProjtasksConfig
