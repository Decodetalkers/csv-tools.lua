local M = {}

--@param buf winbuf
--@param line string
function M.Header()
    local line = unpack(vim.api.nvim_buf_get_lines(0, 0, 1, true))
    local header = {}
    local cout = 1
    local length = 0
    for i = 1, #line do
        if line:sub(i, i) ~= "," then
            length = length + 1
        else
            table.insert(header, length)
            length = 0
            cout = cout + 1
        end
    end
    return header
end
return M
