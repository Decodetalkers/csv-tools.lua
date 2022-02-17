local api = vim.api
local highlight = require("csvtools.highlight")
local overflow = require("csvtools.overflowtext")
local getheader = require("csvtools.header")
local M = {
    before = 20,
    after = 20,
    clearafter = true,
    showoverflow = true,
    titleflow = true,
}
-- buf's status
local Status = {
    winid = nil,
    buf = nil,
    mainwindowbuf = nil,
    header = {},
    overflowtext = {},
}
--function M.printheader()
--    return Status.header
--end
function M.Ifclear()
    if M.clearafter then
        M.clearafter = false
    else
        M.clearafter = true
    end
end
function M.NewWindow()
    if Status.winid == nil then
        Status.mainwindowbuf = vim.api.nvim_get_current_buf()
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
        Status.winid = win
        Status.buf = buf
        M.add_mappings()
    end
end

function M.CloseWindow()
    if Status.winid ~= nil then
        vim.api.nvim_win_close(Status.winid, true)
        Status.winid = nil
        Status.buf = nil
        Status.header = {}
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
-- only 3 overflow
local function getrangeoverflow(line, length)
    local start = 1
    if line - 1 > 1 then
        start = line - 1
    end
    local final = length
    if line + 1 < length then
        final = line + 1
    end
    return start, final
end
function M.Highlight()
    if vim.o.filetype == "csv" then
        Status.header = getheader.Header()
        --if M.showoverflow then
        --    for count = 1, #Status.overflowtext do
        --        vim.api.nvim_buf_del_extmark(
        --            Status.overflowtext[count].markid,
        --            Status.overflowtext[count].ns_id,
        --            Status.overflowtext[count].id
        --        )
        --    end
        --end
        Status.overflowtext = {}
        M.mainwindowbuf = vim.api.nvim_get_current_buf()
        local line, _ = unpack(vim.api.nvim_win_get_cursor(0))
        --print(line)
        local length = vim.api.nvim_buf_line_count(M.mainwindowbuf)
        if M.clearafter then
            api.nvim_buf_clear_highlight(M.mainwindowbuf, -1, 0, length)
        end
        local start, final = getrange(line, length)
        local start2, final2 = getrangeoverflow(line, length)
        --print(start)
        --print(final)
        highlight.highlight(M.mainwindowbuf, line)
        for i = start, line - 1, 1 do
            highlight.highlight(M.mainwindowbuf, i)
        end
        for i = line + 1, final, 1 do
            highlight.highlight(M.mainwindowbuf, i)
        end
        if M.showoverflow then
            table.insert(Status.overflowtext, overflow.OverFlow(line, Status.header, 1))
            local count = 2
            for i = start2, line - 1, 1 do
                table.insert(Status.overflowtext, overflow.OverFlow(i, Status.header, count))
                --highlight.highlight(M.mainwindowbuf, count)
                count = count + 1
            end
            for i = line + 1, final2, 1 do
                table.insert(Status.overflowtext, overflow.OverFlow(i, Status.header, count))
                --highlight.highlight(M.mainwindowbuf, count)
                count = count + 1
            end
            if line - 2 > 0 and M.titleflow then
                table.insert(Status.overflowtext, overflow.OverFlowTitle(line - 2, Status.header, 4))
            end
        end
    end
end
function M.deleteMark()
    if M.showoverflow then
        vim.api.nvim_buf_del_extmark(
            Status.overflowtext[1].markid,
            Status.overflowtext[1].ns_id,
            Status.overflowtext[1].id
        )
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
    vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<leader>tg", ":lua require'csvtools'.Ifclear()<cr>", opts)
    vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<up>", ":-1<cr>:lua require'csvtools'.Highlight()<cr>", opts)
    vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "k", ":-1<cr>:lua require'csvtools'.Highlight()<cr>", opts)
    vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<down>", ":+1<cr>:lua require'csvtools'.Highlight()<cr>", opts)
    vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "j", ":+1<cr>:lua require'csvtools'.Highlight()<cr>", opts)
end
function M.setup(opts)
    M = vim.tbl_deep_extend("force", M, opts)
end
return M
