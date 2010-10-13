color torte
syn on
set ts=4
set sts=4
set sw=4
set cindent
set nowb
set expandtab
set smarttab
set ai
set nocp
set nobk
set ruler

"####################################################################
"#
"# FileType Support
"#
"####################################################################
filetype on
filetype plugin on
filetype indent on

"####################################################################
"#
"# ctags 
"#
"####################################################################
function! UPDATE_TAGS()
  let file = expand("%:p")
  let cmd = 'ctags-exuberant -a -f tags --fields=+iaS --extra=+q '
  let cmd .= shellescape(file)
  call system(cmd)
endfunction

autocmd BufWritePost *.cpp,*.h,*.c,*.rb call UPDATE_TAGS()


map <F7> <esc>:cp<cr>
map <F8> <esc>:cn<cr>

