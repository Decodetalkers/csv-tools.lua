local api = vim.api
local M = {}
function M.hightlight(buf,line)
	local cout = 1
	for i=1 ,#line do
		if line:sub(i,i) ~= '|' then
			if cout % 2 == 0 then
				cout = cout+ 1
				print(line:sub(i,i))
				api.nvim_buf_add_highlight(buf, -1, 'WhidHeader',0,i-1,i)
			else
				cout = cout +1
				api.nvim_buf_add_highlight(buf, -1, 'WhidSubHeader',0,i-1,i)
			end
		end
	end
end
return M
