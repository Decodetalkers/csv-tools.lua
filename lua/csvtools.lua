local api = vim.api
local highlight = require("csvtools.highlight")
local M = {
    winid = nil,
    buf = nil,
    mainwindowbuf = nil,
    before = 20,
    after = 20,
    clearafter = true,
}

function M.NewWindow()
    if M.winid == nil then
        M.mainwindowbuf = vim.api.nvim_get_current_buf()
        --local file = vim.api.nvim_buf_get_name(0)
        --local f = io.open(file, "r")
        local messages = unpack(api.nvim_buf_get_lines(M.mainwindowbuf, 0, 1, true))
        if messages == nil then
            return
        end
        --f:close()
        messages = messages:gsub("%,", "|")
        local buf = api.nvim_create_buf(false, true) -- create new emtpy buffer
        vim.cmd([[sview]])
        api.nvim_win_set_height(0, 1)
        local win = vim.api.nvim_get_current_win()
        api.nvim_buf_set_lines(buf, 0, -1, false, { messages })
        api.nvim_win_set_buf(win, buf)
        highlight.highlighttop(buf, messages)
        --api.nvim_buf_add_highlight(buf, -1, 'WhidHeader',0,0,1)
        --api.nvim_buf_add_highlight(buf, -1, 'WhidSubHeader', 0, 1, 2)
        M.winid = win
        M.buf = buf
        M.add_mappings()
    end
end

function M.CloseWindow()
    if M.winid ~= nil then
        vim.api.nvim_win_close(M.winid, true)
        M.winid = nil
        M.buf = nil
    end
end

--@param line number
--@param length string
--@return number number
local function getrange(line, length)
    local start = 1
    if line - M.before > 1 then
        start = line - M.before
    end
    local final = length
    if line + M.after < length then
        final = line + M.after
    end
    return start, final
end
function M.Highlight()
    if vim.o.filetype == "csv" then
        M.mainwindowbuf = vim.api.nvim_get_current_buf()
        local line, _ = unpack(vim.api.nvim_win_get_cursor(0))
        local length = vim.api.nvim_buf_line_count(M.mainwindowbuf)
        if M.clearafter then
            api.nvim_buf_clear_highlight(M.mainwindowbuf, -1, 0, length)
        end
        local start, final = getrange(line, length)
        --print(start)
        --print(final)
        for i = start, line, 1 do
            highlight.highlight(M.mainwindowbuf, i)
        end
        for i = line, final, 1 do
            highlight.highlight(M.mainwindowbuf, i)
        end
    end
end
function M.add_mappings()
    M.mainwindowbuf = vim.api.nvim_get_current_buf()
    --print(M.mainwindowbuf)
    local opts = { nowait = true, noremap = true, silent = true }
    --vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<leader>td", ":lua require'csvtools'.CloseWindow<cr>", opts)
    vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<leader>tf", ":lua require'csvtools'.NewWindow()<cr>", opts)
    vim.api.nvim_buf_set_keymap(M.buf, "n", "<leader>td", ":lua require'csvtools'.CloseWindow()<cr>", opts)
    vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<leader>td", ":lua require'csvtools'.CloseWindow()<cr>", opts)
    vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<up>", ":lua require'csvtools'.Highlight()<cr>:-1<cr>", opts)
    vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<down>", ":lua require'csvtools'.Highlight()<cr>:+1<cr>", opts)
end
function M.setup(opts)
    M = vim.tbl_deep_extend("force", M, opts)
end
return M
