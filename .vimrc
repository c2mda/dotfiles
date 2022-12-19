" Enable modern Vim features not compatible with Vi spec.
set nocompatible

" Required for eg YouCompleteME
set encoding=utf-8

" Nice status line
set statusline=%F       "tail of the filename
set statusline+=%y      "filetype
set statusline+=%m      "modified flag

" Swap files: all in same directory
set directory=$HOME/.vim/swap/

"======================"
" Vundle configuration "
"======================"
" Install plugins that come from github.  Once Vundle is installed, these can be
" installed with :PluginInstall
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
if isdirectory(expand('$HOME/.vim/bundle/Vundle.vim'))
call vundle#begin()
" Required
Plugin 'gmarik/vundle'

" No longer using syntastic.
" Plugin 'vim-syntastic/syntastic'

" Asynchronous linter.
Plugin 'dense-analysis/ale'

" To comment/uncomment.
Plugin 'preservim/nerdcommenter'

" To move through names with _
Plugin 'bkad/CamelCaseMotion'

" Maktaba: Google vimscript utility.
Plugin 'google/vim-maktaba'

" Codefmt: Google code formatter.
Plugin 'google/vim-codefmt'

" Glaive: Google vim config manager.
Plugin 'google/vim-glaive'

" Vim tmux navigator
Plugin 'christoomey/vim-tmux-navigator'

" FZF.
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'

" Vim outline window.
" Doesn't work great.
" Plugin 'vim-voom/VOoM'

" For autocompletion in Python.
" Actually jedi is not great compared to youcompleteme.
" Plugin 'davidhalter/jedi-vim'

" Autocomplete.
" Also needs:
" sudo apt install build-essential cmake vim-nox python3-dev
" cd ~/.vim/bundle/YouCompleteMe
" python3 install.py --all
Plugin 'ycm-core/YouCompleteMe'

" For automatic deletion of swap files.
Plugin 'gioele/vim-autoswap'

" Tmux vim clipboard integration
" Doesnt work, broken.
" Plugin 'roxma/vim-tmux-clipboard'

" Use OSC52 for clipboard, not X11 (X11 slow on connection)
Plugin 'ojroques/vim-oscyank'

" Indent visible in yaml files.
Plugin 'Yggdroot/indentLine'

" Correct folds in yaml.
Plugin 'pedrohdz/vim-yaml-folds'

" Move based on indent level, useful for YAML.
Plugin 'jeetsukumaran/vim-indentwise'

" Use bracketed mode to paste correctly
Plugin 'ConradIrwin/vim-bracketed-paste'

" Smooth scroll
Plugin 'psliwka/vim-smoothie'

call vundle#end()
call glaive#Install()
else
echomsg 'Vundle is not installed. You can install Vundle from'
    \ 'https://github.com/VundleVim/Vundle.vim'
endif

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

" nice colors even on OSX
colorscheme desert
" desert looks different on OSX and Linux, make Normal consistent.
highlight Normal ctermfg=LightGray ctermbg=Black


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
map <leader>fw :FixWhitespace

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

nnoremap <C-t> :History:<CR>

" Load installed plugins.
packloadall
let g:ale_fixers = {
      \'python': ['reorder-python-imports','autopep8'],
      \'yaml': ['trim_whitespace', 'prettier'],
      \'cpp': ['clang-format'],
      \}
let g:ale_linters = {
      \'python': ['pylint'], 
      \'yaml': ['yamllint'],
      \'cpp': ['clang'],
      \}
let g:ale_cpp_clang_options = '-Wall -O2 -std=c++1z'

" Yamllint doesn't like spaces after curly brackets.
let g:ale_javascript_prettier_options='--bracket-spacing=false'

" Otherwise lnext errors when only one error in list.
function! Lnextwrap()
  try
    :lnext
  catch /^Vim\%((\a\+)\)\=:E553/
    :lfirst
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
hi SpellBad cterm=underline
hi SpellLocal cterm=underline
hi SpellRare cterm=underline
hi SpellCap cterm=underline

" Set the shell interactive, to allows bash aliases such as fd
" Actually setting the shell as interactive causes problems: when running
" external command such as tmux select-pane, vim will get suspended.
" Better way to have aliases available is to define them in .bash_profile
" set shellcmdflag=-ic

" Indent 4 spaces in Python.
autocmd FileType python set shiftwidth=4
autocmd FileType python set tabstop=4
autocmd FileType python set softtabstop=4

" Search in buffers with FZF
nnoremap <C-_> :Lines<CR>

" To use camel case motion,
let g:camelcasemotion_key = ','

" Use local pylint, so it picks up virtual env.
" Otherwise global pylint doesn't know about virtualenv
" packages and claims import are failing.
let g:ale_use_global_executables = 0

" By default pylint runs from directory of global pylintrc.
" But we set init-hook in .pylintrc to add cwd to sys.path
" So runs pylint from current directory instead.
let g:ale_python_pylint_change_directory = 0

" After every yank copy to current terminal system clipboard using OSC52
" https://github.com/ojroques/vim-oscyank
autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif

" Yaml indentation 2 spaces.
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab

" For indentLine plugin
let g:indentLine_char = '⦙'

" Yaml does not require indentation whne using hyphen.
let g:ale_yaml_yamllint_options='-d "{extends: default, rules: {indentation: {indent-sequences: consistent}}}"'

" Start with all folds open.
" https://stackoverflow.com/questions/8316139/how-to-set-the-default-to-unfolded-when-you-open-a-file
autocmd BufWinEnter * silent! :%foldopen!

" To allow YCM to use local python interpreter in virtual_env
" From :help youcompleteme-configuring-through-vim-options
" Also needs a ~/global_extra_conf.py file.
let g:ycm_python_interpreter_path = ''
let g:ycm_python_sys_path = []
let g:ycm_extra_conf_vim_data = [
\  'g:ycm_python_interpreter_path',
\  'g:ycm_python_sys_path'
\]
let g:ycm_global_ycm_extra_conf = '~/global_extra_conf.py'

" YCM commands to get documentation and go to definition
" https://github.com/ycm-core/YouCompleteMe
nnoremap <leader>jd :YcmCompleter GoTo<CR>
nnoremap <leader>jr :YcmCompleter GoToReferences<CR>
nnoremap <leader>jv :YcmCompleter GetDoc<CR>

" Display tabs as \t.
set list
set listchars=tab:\\t

" Disable all bells
set belloff=all

