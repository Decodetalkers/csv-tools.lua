au BufRead,BufNewFile *.csv,*.dat,*.tsv,*.tab set filetype=csv
au FileType csv command! -buffer CloseTopWindow lua require"csvtools".CloseWindow()
au FileType csv command! -buffer TopWindow lua require"csvtools".NewWindow()
autocmd! InsertEnter *.csv,*.bat,*.tsv,*.tab lua require"csvtools".deleteMark()
"au FIiletype csv autocmd CursorMoved csv lua require"csvtools".Highlight()
