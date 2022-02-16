local api = vim.api
local highlight = require("csvtools.highlight")
local overflow = require("csvtools.overflowtext")
local M = {
    winid = nil,
    buf = nil,
    mainwindowbuf = nil,
	header = {},
    before = 20,
    after = 20,
    clearafter = true,
	overflowtext = {
		markid = nil,
		ns_id = nil,
		id = nil,
	}
}
function M.printheader()
	--for count = 1, #M.header do
	--	print(M.header[count])
	--end
	return M.header
end
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
        M.header = highlight.highlighttop(buf, messages)
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
		M.header = {}
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
		--print(line)
        local length = vim.api.nvim_buf_line_count(M.mainwindowbuf)
        if M.clearafter then
            api.nvim_buf_clear_highlight(M.mainwindowbuf, -1, 0, length)
        end
        local start, final = getrange(line, length)
        --print(start)
        --print(final)
		M.overflowtext= overflow.OverFlow(line,M.header)
        for i = start, line, 1 do
            highlight.highlight(M.mainwindowbuf, i)
        end
        for i = line, final, 1 do
            highlight.highlight(M.mainwindowbuf, i)
        end
    end
end
function M.deleteMark()
	vim.api.nvim_buf_del_extmark(
		M.overflowtext.markid,
		M.overflowtext.ns_id,
		M.overflowtext.id
	)
end
function M.add_mappings()
    M.mainwindowbuf = vim.api.nvim_get_current_buf()
    --print(M.mainwindowbuf)
    local opts = { nowait = true, noremap = true, silent = true }
    --vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<leader>td", ":lua require'csvtools'.CloseWindow<cr>", opts)
    vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<leader>tf", ":lua require'csvtools'.NewWindow()<cr>", opts)
    vim.api.nvim_buf_set_keymap(M.buf, "n", "<leader>td", ":lua require'csvtools'.CloseWindow()<cr>", opts)
    vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<leader>td", ":lua require'csvtools'.CloseWindow()<cr>", opts)
    vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<up>", ":-1<cr>:lua require'csvtools'.Highlight()<cr>", opts)
    vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<down>", ":+1<cr>:lua require'csvtools'.Highlight()<cr>", opts)
end
function M.setup(opts)
    M = vim.tbl_deep_extend("force", M, opts)
end
return M
