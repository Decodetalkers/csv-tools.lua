local api = vim.api
local M = {}
function M.highlighttop(buf, line)
    local cout = 1
    for i = 1, #line do
        if line:sub(i, i) ~= "|" then
            if cout % 2 == 0 then
                --print(line:sub(i, i))
                api.nvim_buf_add_highlight(buf, -1, "WhidHeader", 0, i - 1, i)
            else
                api.nvim_buf_add_highlight(buf, -1, "WhidSubHeader", 0, i - 1, i)
            end
        else
            cout = cout + 1
        end
    end
end
function M.highlight(buf, number)
    local line = unpack(vim.api.nvim_buf_get_lines(buf, number - 1, number, true))
    --print(line)
    local cout = 1
    for i = 1, #line do
        if line:sub(i, i) ~= "," then
            if cout % 2 == 0 then
                --print(line:sub(i, i))
                api.nvim_buf_add_highlight(buf, -1, "WhidHeader", number - 1, i - 1, i)
            else
                api.nvim_buf_add_highlight(buf, -1, "WhidSubHeader", number - 1, i - 1, i)
            end
        else
            cout = cout + 1
        end
    end
end
return M
