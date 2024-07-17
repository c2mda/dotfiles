" Enable modern Vim features not compatible with Vi spec.
set nocompatible

" Required for eg YouCompleteME
set encoding=utf-8

" Swap files: all in same directory
set directory=$HOME/.vim/swap/

filetype off

"" Install vim-plug if we don't already have it
if empty(glob('~/.vim/autoload/plug.vim'))
silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" Asynchronous linter.
Plug 'dense-analysis/ale'

" To comment/uncomment.
Plug 'preservim/nerdcommenter'

" To move through names with _
Plug 'bkad/CamelCaseMotion'

" Vim tmux navigator
Plug 'christoomey/vim-tmux-navigator'

" FZF.
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" Peekaboo to view register contents before pasting.
Plug 'junegunn/vim-peekaboo'

" Autocomplete.
" Also needs:
" sudo apt install build-essential cmake vim-nox python3-dev
" cd ~/.vim/bundle/YouCompleteMe
" python3 install.py --all
Plug 'ycm-core/YouCompleteMe'

" For automatic deletion of swap files.
Plug 'gioele/vim-autoswap'

" Use OSC52 for clipboard, not X11 (X11 slow on connection)
Plug 'ojroques/vim-oscyank'

" Indent visible in yaml files.
" Plug 'Yggdroot/indentLine'

" Correct folds in yaml.
Plug 'pedrohdz/vim-yaml-folds'

" Move based on indent level, useful for YAML.
Plug 'jeetsukumaran/vim-indentwise'

" Use bracketed mode to paste correctly
Plug 'ConradIrwin/vim-bracketed-paste'

" Smooth scroll
" Plug 'psliwka/vim-smoothie'

" Git tools
Plug 'tpope/vim-fugitive'

" Jsonnet syntax highlighting
Plug 'google/vim-jsonnet'

" Tagbar
Plug 'preservim/tagbar'

" Show git status of lines in gutter.
Plug 'mhinz/vim-signify'

call plug#end()

filetype plugin indent on

" Use system clipboard
set clipboard=unnamed

" Line numbers
set number

" No tabs, use spaces
set expandtab

" Two spaces per tab
set tabstop=2
set softtabstop=2

" Indenting indents by 2 spaces
set shiftwidth=2

" Search is incremental
set incsearch

" Ignore case when searching
set ignorecase

" Enable syntax highlighting.
syntax on


" Allow erasing indent.
set backspace=indent,eol,start

" http://stackoverflow.com/questions/6453595/prevent-vim-from-clearing-the-clipboard-on-exit
autocmd VimLeave * call system("xsel -ib", getreg('+'))

" Put plugins and dictionaries in this dir (also on Windows)
let vimDir = '$HOME/.vim'
let &runtimepath.=','.vimDir

" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
  let myUndoDir = expand(vimDir . '/undodir')
  " Create dirs
  call system('mkdir ' . vimDir)
  call system('mkdir ' . myUndoDir)
  let &undodir = myUndoDir
  set undofile
endif

map <leader>fc :ALEFix<CR>

map <leader>sc :write<CR>:ALELint<CR>

" Map \fsc to format + lint
map <leader>fsc :write<CR>:ALEFix<CR>:write<CR>:ALELint<CR>

" File types to autoformat on save
augroup autoformat_settings
au BufReadPost *.ejs set syntax=html
autocmd FileType javascript AutoFormatBuffer prettier
augroup END

" Always show status bar.
set laststatus=2

" Show insert / normal
set showmode


" absolute width of netrw window
let g:netrw_winsize = -28

" do not display info on the top of window
let g:netrw_banner = 0

" tree-view
let g:netrw_liststyle = 3

" sort is affecting only: directories on the top, files below
let g:netrw_sort_sequence = '[\/]$,*'

" mouse doesnt copy line numbers, mouse scrolling
set mouse=a

" nice colors even on OSX
colorscheme desert

" Nice status line
highlight IsModified ctermbg=darkred guibg=darkred
highlight StatusLine ctermfg=Gray guifg=Gray ctermbg=Black guibg=Black
highlight NonText term=bold cterm=bold ctermfg=4 gui=bold ctermfg=LightBlue guifg=LightBlue guibg=Black ctermbg=Black

fu! MyStatusLine() abort
    return (&mod? '%#IsModified#% %m%F:' : ' %m%F:') . tagbar#currenttag("%s","","f","scoped-stl")
endfu
set statusline=%!MyStatusLine()

" desert looks different on OSX and Linux, make Normal consistent.
highlight Normal ctermfg=LightGray ctermbg=Black guifg=LightGray guibg=Black
" default diffchange color is flashy magenta
highlight DiffChange ctermbg=LightYellow guibg=LightYellow

" white on black menu for autocompletion -- must be after colorscheme
highlight Pmenu ctermfg=15 ctermbg=0 guifg=#ffffff guibg=#000000

" Highlight lines over 80 chars grey on darkred -- must be after colorscheme
highlight OverLength ctermbg=88 ctermfg=grey guibg=#592929
match OverLength /\%81v.\+/

" NERDCommenter: add space after #
let g:NERDSpaceDelims=1

" Allow commenting empty lines.
let g:NERDCommentEmptyLines = 1

" Remove trailing whitespace.
command FixWhitespace %s/\s\+$//e
map <leader>fw :FixWhitespace<CR>

" Allow switching buffers without saving.
set hidden

" Search and replace does not use regex
set nomagic

" Enable spell checking.
set spell spelllang=en_us

" Remove capitalization spell check, fails with Args: in docstrings.
set spellcapcheck=

" Use jsBeautify to format javascript.
" autocmd FileType javascript AutoFormatBuffer clang-format
" autocmd FileType javascript setlocal equalprg=js-beautify\ --stdin
" autocmd FileType javascript AutoFormatBuffer prettier
"
set omnifunc=syntaxcomplete#Complete

" Load installed plugins.
packloadall
" Yamlfix is good but indentation doesnt agree with yamllint
" prettier + yamlfix seems to agree with yamllint
      " \'yaml': ['trim_whitespace', 'yamlfix', 'prettier'],
let g:ale_fixers = {
      \'python': ['trim_whitespace', 'ruff', 'autopep8', 'autoflake', 'isort', 'black'],
      \'yaml': ['trim_whitespace', 'prettier'],
      \'cpp': [],
      \'markdown': ['pandoc'],
      \'sh': ['trim_whitespace', 'remove_trailing_lines', 'shfmt'],
      \}
let g:ale_linters = {
      \'python': ['ruff', 'mypy'],
      \'yaml': ['yamllint'],
      \'cpp': [],
      \'markdown': ['pandoc'],
      \'sh': ['shellcheck'],
      \}
let g:ale_cpp_clang_options = '-Wall -O2 -std=c++1z'
let g:ale_sh_shfmt_options = '-i 2' " Indent shell script with 2 spaces.
let g:ale_fix_on_save = 0  " This removes 'useless' imports in __init__.py


" Yamllint doesn't like spaces after curly brackets.
let g:ale_javascript_prettier_options='--bracket-spacing=false'

" Black takes care of line length, ruff is too strict.
" E501 is line > 88 chars.
let ale_python_ruff_options="--ignore E501"

" Otherwise lnext errors when one or zero errors in list.
function! Lnextwrap()
  try
    :lnext
  catch /^Vim\%((\a\+)\)\=:E553/
    :lfirst
  catch /^Vim\%((\a\+)\)\=:E42/
    :echo "No errors."
  endtry
endfunction

" Map \lo, \ln, \lp, \lc to lopen, lclose, lnext, lprevious
map <leader>lo :lopen <CR>
map <leader>lc :lclose <CR>
map <leader>lp :lprevious <CR>
map <leader>ln :call Lnextwrap()<CR>

" Highlight spell mistake by underlining.
hi clear SpellBad
hi clear SpellLocal
hi clear SpellRare
hi clear SpellCap
hi SpellBad cterm=underline gui=underline
hi SpellLocal cterm=underline gui=underline
hi SpellRare cterm=underline gui=underline
hi SpellCap cterm=underline gui=underline

" Set the shell interactive, to allows bash aliases such as fd
" Actually setting the shell as interactive causes problems: when running
" external command such as tmux select-pane, vim will get suspended.
" Better way to have aliases available is to define them in .bash_profile
" set shellcmdflag=-ic

" Indent 4 spaces in Python.
autocmd FileType python set shiftwidth=4
autocmd FileType python set tabstop=4
autocmd FileType python set softtabstop=4

" To use camel case motion,
let g:camelcasemotion_key = ','

" Use local pylint, so it picks up virtual env.
" Otherwise global pylint doesn't know about virtualenv
" packages and claims import are failing.
let g:ale_use_global_executables = 0

" After every yank copy to current terminal system clipboard using OSC52
" https://github.com/ojroques/vim-oscyank
autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankRegister "' | endif

" Yaml indentation 2 spaces.
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

" For indentLine plugin
" let g:indentLine_char = '⦙'

" Yaml does not require indentation whne using hyphen.
let g:ale_yaml_yamllint_options='-d "{extends: default, rules: {indentation: {indent-sequences: consistent}}}"'

" Start with all folds open.
" https://stackoverflow.com/questions/8316139/how-to-set-the-default-to-unfolded-when-you-open-a-file
autocmd BufWinEnter * silent! :%foldopen!

" To allow YCM to use local python interpreter in virtual_env
" From :help youcompleteme-configuring-through-vim-options
" Also needs a ~/global_extra_conf.py file.
" https://github.com/ycm-core/YouCompleteMe?tab=readme-ov-file#configuring-through-vim-options
let g:ycm_python_interpreter_path = ''
let g:ycm_python_sys_path = []
let g:ycm_extra_conf_vim_data = [
\  'g:ycm_python_interpreter_path',
\  'g:ycm_python_sys_path'
\]
let g:ycm_global_ycm_extra_conf = '~/global_extra_conf.py'

" YCM commands to get documentation and go to definition
" https://github.com/ycm-core/YouCompleteMe
" Display tabs as \t.
set list
set listchars=tab:\\t

" Disable all bells
set belloff=all

" ZZ also exits command line window (opened with q:)
" https://superuser.com/questions/286985/reload-vimrc-in-vim-without-restart
augroup CommandLineWindow
    autocmd!
    autocmd CmdwinEnter * nnoremap <buffer> ZZ :q<cr>
augroup END

" Compact tagbar
let g:tagbar_compact = 1

" Set tmux pane title to vim so tmux knows it's vim even under ssh.
" Need to also change tmux to recognize this.
" autocmd VimEnter * silent :!printf "\033]2;vim\033\\"
" autocmd VimLeave * silent :!printf "\033]2;blah\033\\"

""""""" SHORTCUTS

" No Ex mode
nnoremap Q <nop>

nnoremap <C-e> :FZF<CR>
nnoremap <C-t> :History:<CR>

" Search in buffers with FZF
nnoremap <C-q> :Lines<CR>
nnoremap <leader>vb :Buffers<CR>

" Search everywhere with ripgrep+FZF
nnoremap <C-_> :Rg<CR>

nnoremap <leader>jd :YcmCompleter GoTo<CR>
nnoremap <leader>jr :YcmCompleter GoToReferences<CR>
nnoremap <leader>jv :YcmCompleter GetDoc<CR>
nnoremap <leader>jo :TagbarToggle<CR>


fun! WriteIfNotEmptyQuitIfLast(save) abort
  let bytes = wordcount().bytes
  let fn = expand('%')
  " If we're on a meaningful buffer (not empty default)
  " maybe write.
  if (len(fn) > 0 || bytes > 1) && a:save
    write
    bdelete
  else
    bdelete!
  endif

  " If no buffer left quit.
  let bufcnt = len(filter(range(1, bufnr('$')), 'buflisted(v:val)'))
  if bufcnt < 2
      quit!
  endif
endfun

" XX to write and close buffer
nnoremap XX :call WriteIfNotEmptyQuitIfLast(1)<CR>
" XQ to close buffer without saving
nnoremap XQ :call WriteIfNotEmptyQuitIfLast(0)<CR>

" C-S to save file
" https://stackoverflow.com/questions/3446320/in-vim-how-to-map-save-to-ctrl-s
" update is no-op if buffer not modified
noremap <silent> <C-S>          :update<CR>
vnoremap <silent> <C-S>         <C-C>:update<CR>
inoremap <silent> <C-S>         <C-O>:update<CR>


" Enable 24 bit colors, see https://www.reddit.com/r/vim/comments/g04s8u/how_to_enable_true_color_support_in_vim/
" or :help xterm-true-color
let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors
