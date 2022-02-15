local api = vim.api

local M = {
	winid = nil,
	buf = nil,
	mainwindowbuf = nil
}
function M.NewWindow()
	if M.winid == nil then
		M.mainwindowbuf = vim.api.nvim_get_current_buf()
		local file = vim.api.nvim_buf_get_name(0)
		local f = io.open(file,"r")

		local messages = f:read()
		if messages == nil then
			return
		end
		f:close()
		messages= messages:gsub("%,","|")
		local buf = api.nvim_create_buf(false, true) -- create new emtpy buffer
		vim.cmd[[sview]]
		api.nvim_win_set_height(0, 1)
		local win = vim.api.nvim_get_current_win()
		api.nvim_buf_set_lines(buf, 0, -1, false, { messages })
		api.nvim_win_set_buf(win,buf)
		require("csvtools.topbarhighlight").hightlight(buf,messages)
		--api.nvim_buf_add_highlight(buf, -1, 'WhidHeader',0,0,1)
		--api.nvim_buf_add_highlight(buf, -1, 'WhidSubHeader', 0, 1, 2)
		M.winid = win
		M.buf = buf
		M.add_mappings()
	end
end
function M.CloseWindow()
	if M.winid ~=nil then
		vim.api.nvim_win_close(M.winid,true)
		M.winid = nil
		M.buf = nil
	end
end
function M.add_mappings()
	--print(M.mainwindowbuf)
	local opts = { nowait = true, noremap = true, silent = true }
	--vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<leader>td", ":lua require'csvtools'.CloseWindow<cr>", opts)
	vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<leader>tf", ":lua require'csvtools'.NewWindow()<cr>", opts)
	vim.api.nvim_buf_set_keymap(M.buf, "n", "<leader>td", ":lua require'csvtools'.CloseWindow()<cr>", opts)
	vim.api.nvim_buf_set_keymap(M.mainwindowbuf, "n", "<leader>td", ":lua require'csvtools'.CloseWindow()<cr>", opts)
end
function M.setup(opts)
	M = vim.tbl_deep_extend("force",M, opts)
end
return M
