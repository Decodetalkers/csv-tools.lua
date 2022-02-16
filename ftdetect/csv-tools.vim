au BufRead,BufNewFile *.csv,*.dat,*.tsv,*.tab set filetype=csv
au FileType csv command! -buffer CloseTopWindow lua require"csvtools".CloseWindow()
au FileType csv command! -buffer TopWindow lua require"csvtools".NewWindow()
