" Enable modern Vim features not compatible with Vi spec.
set nocompatible

" Required for eg YouCompleteME
set encoding=utf-8

" Nice status line
set statusline=%F       "tail of the filename
" set statusline+=%h      "help file flag
" set statusline+=%r      "read only flag
set statusline+=%y      "filetype
set statusline+=%m      "modified flag
" set statusline+=%=      "left/right separator
" set statusline+=%c,     "cursor column
" set statusline+=%l/%L   "cursor line/total lines

"======================"
" Vundle configuration "
"======================"
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
if isdirectory(expand('$HOME/.vim/bundle/Vundle.vim'))
call vundle#begin()
" Required
Plugin 'gmarik/vundle'
" Install plugins that come from github.  Once Vundle is installed, these can be
" installed with :PluginInstall

" Plugin 'vim-syntastic/syntastic'
Plugin 'dense-analysis/ale'

" To comment/uncomment.
Plugin 'preservim/nerdcommenter'

" Fuzzy searcher.
Plugin 'tpope/tpope-vim-abolish'

Plugin 'google/vim-maktaba'
Plugin 'google/vim-codefmt'
Plugin 'google/vim-glaive'

" Vim tmux navigator
Plugin 'christoomey/vim-tmux-navigator'
call vundle#end()
call glaive#Install()
else
echomsg 'Vundle is not installed. You can install Vundle from'
    \ 'https://github.com/VundleVim/Vundle.vim'
endif

call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
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

" Indenting indents by 2 spaces
set shiftwidth=2 expandtab

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

" Map \fc to FormatCode
" map <leader>fc :FormatCode <CR>
map <leader>fc :ALEFix<CR>

" Map \sc to SyntasticCheck
" map <leader>sc :write<CR>:SyntasticCheck<CR>
" let g:syntastic_mode_map = {'mode': 'passive'}  " No syntax check on :w
" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 0
" let g:syntastic_check_on_open = 0
" let g:syntastic_check_on_wq = 0
" let g:syntastic_python_checker_args="--single-file=y"
" let g:syntastic_auto_jump = 1
" " Map \lo, \ln, \lp, \lc to lopen, lclose, lnext, lprevious
" map <leader>lo :lopen <CR>
" map <leader>lc :lclose <CR>
" map <leader>lp :lprevious <CR>
" map <leader>ln :lnext <CR>
" let g:syntastic_javascript_checkers=['eslint']
" let g:syntastic_html_checkers=['validator']
 map <leader>sc :write<CR>:ALELint<CR>

" Map \fsc to format + syntastic
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

" No Ex mode
nnoremap Q <nop>

nnoremap <C-e> :FZF<CR>

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

" nice colors
colorscheme desert

" white on black menu for autocompletion -- must be after colorscheme
highlight Pmenu ctermfg=15 ctermbg=0 guifg=#ffffff guibg=#000000

" Highlight lines over 80 chars -- must be after colorscheme
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/

" NERDCommenter: add space after #
let g:NERDSpaceDelims=1

" Allow commenting empty lines.
let g:NERDCommentEmptyLines = 1

" Swap files: all in same directory
set directory=/Users/x/.vim/swap/

" Remove trailing whitespace.
command FixWhitespace %s/\s\+$//e
map <leader>fw :FixWhitespace

" Allow switching buffers without saving.
set hidden

" Search and replace does not use regex
set nomagic

" Set proper colorscheme for vimdiff.
if &diff
    colorscheme cypdiffcolorscheme
endif

" Enable spell checking.
set spell spelllang=en_us

" Remove capitalization spell check, fails with Args: in docstrings.
set spellcapcheck=

" Use jsBeautify to format javascript.
" autocmd FileType javascript AutoFormatBuffer clang-format
" autocmd FileType javascript setlocal equalprg=js-beautify\ --stdin
" autocmd FileType javascript AutoFormatBuffer prettier

map <C-a> <esc>ggVG<CR>

filetype plugin on
set omnifunc=syntaxcomplete#Complete

nnoremap <C-t> :History:<CR>
      
" Load installed plugin (prettier for javascript)
packloadall
let g:ale_fixers = {'python': ['reorder-python-imports','autopep8']}
let g:ale_linters = {'python': ['pylint']}

" Map \lo, \ln, \lp, \lc to lopen, lclose, lnext, lprevious
map <leader>lo :lopen <CR>
map <leader>lc :lclose <CR>
map <leader>lp :lprevious <CR>
map <leader>ln :lnext <CR>

" Highlight spell mistake by underlining.
hi clear SpellBad
hi clear SpellLocal
hi clear SpellRare
hi clear SpellCap
hi SpellBad cterm=underline
hi SpellLocal cterm=underline
hi SpellRare cterm=underline
hi SpellCap cterm=underline
