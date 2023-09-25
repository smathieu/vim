scriptencoding utf-8
set encoding=utf-8

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

autocmd BufWritePost *.scala,*.cpp,*.h,*.c,*.rb,*.js,*.coffee,*.php call UPDATE_TAGS()

autocmd FileType haml,ruby,eruby,yaml,javascript,coffee,scala,python,cpp,c set ai sw=2 sts=2 et tw=100
autocmd FileType txt set tw=80

au BufNewFile,BufRead *.pill,Capfile,Berksfile,Guardfile,Procfile,*.god,*.rabl set filetype=ruby
au BufNewFile,BufRead *.hamljs,*.hamlc set filetype=haml
au BufNewFile,BufRead *.less set filetype=css
au BufNewFile,BufRead Gruntfile set filetype=javascript
au BufNewFile,BufRead BUILD,SConstruct,SConstscript,*.aurora set filetype=python

au BufNewFile,BufRead *.sbt,*.thrift set filetype=scala tw=100
au BufNewFile,BufRead *.md set filetype=markdown

autocmd FileType markdown set tw=0

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
map <leader>, :CtrlP getcwd()<cr>

" Ignore extra things in ctrlp
set wildignore+=tags
set wildignore+=*/tmp/*
set wildignore+=*/node_modules/*
set wildignore+=*/spec/reports/*
set wildignore+=*/bower/*
set wildignore+=*/logs?/*
set wildignore+=*/spec/vcr/*
set wildignore+=./public/*
set wildignore+=*/chef/*
set wildignore+=*/coverage/*
set wildignore+=*/build/*
set wildignore+=*.png,*.jpg,*.otf,*.woff,*.jpeg,*.orig,*.o

let g:ctrlp_max_files = 100000

function! RunTestFile(...)
    if a:0
        let command_suffix = a:1
    else
        let command_suffix = ""
    endif

    " Run the tests for the previously-marked file.
    let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|_test.rb\|_spec.coffee\|\.test\.js\|\.test\.tsx\|\.test\.ts\)$') != -1
    let in_gemfile = match(expand("%"), '\(Gemfile\)$') != -1 || match(expand("%"), '\(\.gemspec\)$') != -1
    let in_script = match(expand("%"), 'scripts\/') != -1
    if in_test_file
      echo "in test file"
        call SetTestFile(command_suffix)
    elseif in_gemfile
        exec ":!run-command bundle install"
        return
    elseif in_script
        exec ":!run-command ./bin/rails runner " . expand("%")
        return
    elseif !exists("t:grb_test_file")
        return
    end
    call RunTests(t:grb_test_file)
endfunction

function! RunNearestTest()
    let spec_line_number = line('.')
    let in_js = match(expand("%"), '\.test\.tsx$') != -1
    if in_js
      let line_text = getline('.')
      let spec_line_number = matchstr(line_text, 'test(')
      let test_name = substitute(line_text, 'it("\(.*\)".*', '\1', '')
      call RunTestFile("--testNamePattern " . test_name)
    else
      call RunTestFile(":" . spec_line_number)
    end
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
    if match(a:filename, '\.feature$') != -1 && filereadable("script/features")
        exec ":!script/features " . a:filename
    else
        if filereadable("script/test")
            exec ":!script/test " . a:filename
        elseif filereadable(expand("~/.vim/bin/run_test"))
            echo ":!" . expand("~/.vim/bin/run_test") . " " . a:filename
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


set listchars=tab:▸\ ,trail:·
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
au BufNewFile,BufReadPost *.txt set tw=0

" golang
au BufNewFile,BufReadPost *.go set nolist

function! ClearAllCtrlPCachesOnNewFile()
  if !filereadable(expand('%'))
      ClearAllCtrlPCaches
  endif
endfunction

au BufWritePre * call ClearAllCtrlPCachesOnNewFile()

" Puppet
au BufNewFile,BufReadPost *.pp set tw=0

au FocusLost * silent! wa

if filereadable('custom.vimrc')
  source custom.vimrc
end

if filereadable(expand('~/.vimrc-local'))
  source ~/.vimrc-local
end

let g:ackprg = "ack -H --nocolor --nogroup --column --smart-case --follow"
noremap <Leader>f :Ack "\b<cword>\b"<cr>

" Convert ruby hash to new style
nmap <leader>h :s/\:\([a-zA-Z_]*\)\s=>/\1\:/g<cr>
vmap <leader>h :s/\:\([a-zA-Z_]*\)\s=>/\1\:/g<cr>

nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

" ALE
let js_fixers = ['prettier', 'eslint']
let g:ale_fixers = {
\   'javascript': js_fixers,
\   'javascript.jsx': js_fixers,
\   'typescript': js_fixers,
\   'typescriptreact': js_fixers,
\   'css': ['prettier'],
\   'json': ['prettier'],
\   'ruby': ['rubocop'],
\}

let g:ale_fix_on_save = 1

highlight ALEWarning gui=undercurl guisp=#fac864
"highlight ALEError gui=undercurl guisg=#ec5f67
let g:ale_ruby_rubocop_executable = 'bundle'

let g:UltiSnipsExpandTrigger="<cr>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"


imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true
nmap <leader>s :ALEFix<cr>
