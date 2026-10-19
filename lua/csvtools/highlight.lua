--local api = vim.api
local M = {}

local ns = vim.api.nvim_create_namespace("csvtools")

---@param buf integer
---@param line string
function M.highlighttop(buf, line)
    --local header = {}
    local cout = 1
    --local length = 0
    for i = 1, #line do
        if line:sub(i, i) ~= "|" then
            if cout % 2 == 0 then
                vim.api.nvim_buf_set_extmark(buf, ns, 0, i - 1, { hl_group = "WhidHeader" })
            else
                vim.api.nvim_buf_set_extmark(buf, ns, 0, i - 1, { hl_group = "WhidSubHeader" })
            end
        else
            cout = cout + 1
        end
    end
    --return header
end

---@param buf integer
---@param number number
function M.highlight(buf, number)
    local line = unpack(vim.api.nvim_buf_get_lines(buf, number - 1, number, true))
    --print(line)
    local cout = 1
    for i = 1, #line do
        if line:sub(i, i) ~= "," then
            if cout % 2 == 0 then
                --print(line:sub(i, i))
                vim.api.nvim_buf_set_extmark(buf, ns, number - 1, i - 1, { hl_group = "WhidHeader" })
            else
                vim.api.nvim_buf_set_extmark(buf, ns, number - 1, i - 1, { hl_group = "WhidSubHeader" })
            end
        else
            cout = cout + 1
        end
    end
end

return M
