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

autocmd BufWritePost *.cpp,*.h,*.c,*.rb,*.js call UPDATE_TAGS()

autocmd FileType ruby,eruby,yaml,javascript set ai sw=2 sts=2 et


map <F7> <esc>:cp<cr>
map <F8> <esc>:cn<cr>
map <F5> <esc>:tp<cr>
map <F6> <esc>:tn<cr>

if has("gui_running") 
  highlight SpellBad term=underline gui=undercurl guisp=Orange 
endif 

" Find file in current directory and edit it.
function! Find(name)
  let l:list=system("find . -name '".a:name."' | perl -ne 'print \"$.\\t$_\"'")
  let l:num=strlen(substitute(l:list, "[^\n]", "", "g"))
  if l:num < 1
    echo "'".a:name."' not found"
    return
  endif
  if l:num != 1
    echo l:list
    let l:input=input("Which ? (CR=nothing)\n")
    if strlen(l:input)==0
      return
    endif
    if strlen(substitute(l:input, "[0-9]", "", "g"))>0
      echo "Not a number"
      return
    endif
    if l:input<1 || l:input>l:num
      echo "Out of range"
      return
    endif
    let l:line=matchstr("\n".l:list, "\n".l:input."\t[^\n]*")
  else
    let l:line=l:list
  endif
  let l:line=substitute(l:line, "^[^\t]*\t./", "", "")
  execute ":e ".l:line
endfunction
command! -nargs=1 Find :call Find("<args>")

