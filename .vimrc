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

" Store temporary files in a central spot
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

" Longer history
set hi=1000

" No error bell
set noerrorbells
set visualbell
set t_vb=

let mapleader=","

"####################################################################
"#
"# FileType Support
"#
"####################################################################
filetype on
filetype plugin on
filetype indent on
syntax on

"####################################################################
"#
"# ctags 
"#
"####################################################################
function! UPDATE_TAGS()
  let file = expand("%:p")
  let cmd = 'ctags -a -f tags --fields=+iaS --extra=+q '
  let cmd .= shellescape(file)
  call system(cmd)
endfunction

autocmd BufWritePost *.scala,*.cpp,*.h,*.c,*.rb,*.js,*.coffee call UPDATE_TAGS()

autocmd FileType haml,ruby,eruby,yaml,javascript,coffee set ai sw=2 sts=2 et tw=80
autocmd FileType txt set tw=80

au BufNewFile,BufRead *.pill,Capfile,Guardfile,Procfile set filetype=ruby
au BufNewFile,BufRead *.hamljs,*.hamlc set filetype=haml
au BufNewFile,BufRead *.less set filetype=css
au BufNewFile,BufRead Gruntfile set filetype=javascript

au BufNewFile,BufRead *.sbt,*.thrift set filetype=scala tw=80
au BufNewFile,BufRead *.md set filetype=markdown

" Insert a hash rocket with <c-l>
imap <c-l> <space>=><space>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ARROW KEYS ARE UNACCEPTABLE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <Left> <Nop>
map <Right> <Nop>
map <Up> <Nop>
map <Down> <Nop>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PROMOTE VARIABLE TO RSPEC LET
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! PromoteToLet()
  :normal! dd
  " :exec '?^\s*it\>'
  :normal! P
  :.s/\(\w\+\) = \(.*\)$/let(:\1) { \2 }/
  :normal ==
endfunction
:command! PromoteToLet :call PromoteToLet()
:map <leader>p :PromoteToLet<cr>


" if has("gui_running") 
"   highlight SpellBad term=underline gui=undercurl guisp=Orange 
" endif 

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RUNNING TESTS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>t :wa\|:call RunTestFile()<cr><cr>
map <leader>T :call RunNearestTest()<cr><cr>
map <leader>a :call RunTests('')<cr><cr>
map <leader>c :w\|:!script/features<cr><cr>
map <leader>w :w\|:!script/features --profile wip<cr><cr>
map <leader>, :CtrlP<cr>

function! RunTestFile(...)
    if a:0
        let command_suffix = a:1
    else
        let command_suffix = ""
    endif

    " Run the tests for the previously-marked file.
    let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|_test.rb\)$') != -1
    let in_gemfile = match(expand("%"), '\(Gemfile\)$') != -1
    if in_test_file
        call SetTestFile(command_suffix)
    elseif in_gemfile
        exec ":!run-command bundle install"
        return
    elseif !exists("t:grb_test_file")
        return
    end
    call RunTests(t:grb_test_file)
endfunction

function! RunNearestTest()
    let spec_line_number = line('.')
    call RunTestFile(":" . spec_line_number)
endfunction

function! SetTestFile(suffix)
    " Set the spec file that tests will be run for.
    let t:grb_test_file=@% . a:suffix
endfunction

function! RunTests(filename)
    " Write the file and run tests for the given filename
    :w
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    :silent !echo;echo;echo;echo;echo;echo;echo;echo;echo;echo
    if match(a:filename, '\.feature$') != -1
        exec ":!script/features " . a:filename
    else
        if filereadable("script/test")
            exec ":!script/test " . a:filename
        elseif filereadable(expand("~/.vim/bin/run_test"))
            exec ":!" . expand("~/.vim/bin/run_test") . " " . a:filename
        elseif filereadable("Gemfile")
            exec ":!bundle exec ruby -Itest " . a:filename
        elseif isdirectory("spec")
            exec ":!rspec " . a:filename
        else
            exec ":!ruby -Itest " . a:filename
        end
    end
endfunction


let os = substitute(system('uname'), "\n", "", "")

" Linux only
if os == "Linux"
    " Remap normal copy paste 
    nmap <C-V> "+gP
    imap <C-V> <ESC><C-V>i
    vmap <C-C> "+y
endif


set listchars=tab:▸\ 
set list

" Use Node.js for JavaScript interpretation
let $JS_CMD='node'

command! Todo :e ~/Dropbox/todo.txt

" Pathogen config
call pathogen#infect()

" Coffeescript
au BufNewFile,BufReadPost *.coffee setl foldmethod=indent nofoldenable
au BufNewFile,BufReadPost *.coffee setl foldmethod=indent
au BufNewFile,BufReadPost *.coffee setl shiftwidth=2 expandtab
au BufNewFile,BufReadPost *.coffee hi link coffeeSpaceError NONE

" Puppet
au BufNewFile,BufReadPost *.pp set tw=0

au FocusLost * silent! wa

if filereadable('custom.vimrc')
  source custom.vimrc
end
