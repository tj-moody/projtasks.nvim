---@alias projtasks { [string]: { build: string, run: string, test: string} }

---@class ProjtasksConfig
---@field terminal_direction? "vertical" | "horizontal"
---@field defaults? projtasks
