" Heavliy influced by http://stackoverflow.com/a/1639391
" VIM Ref: http://vimdoc.sourceforge.net/htmldoc/quickref.html#option-list

scriptencoding utf-8
set encoding=utf-8
set nocompatible                   " break away from old vi compatibility

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-plug
" vim +PlugInstall
call plug#begin('~/.vim/plugged')
" let Vundle manage Vundle, required
Plug 'gmarik/Vundle.vim'
Plug 'tpope/vim-sensible'
Plug 'scrooloose/nerdtree'
Plug 'editorconfig/editorconfig-vim'
"Plug 'endel/vim-github-colorscheme'
Plug 'romainl/Apprentice'
Plug 'altercation/vim-colors-solarized'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tmhedberg/SimpylFold'
Plug 'vim-syntastic/syntastic'
Plug 'myint/syntastic-extras'  " Adds additional "basic" filetype checkers
Plug 'Valloric/YouCompleteMe', { 'commit':'d98f896' }
"Plug 'ctrlpvim/ctrlp.vim'

"Plug 'chase/vim-ansible-yaml'
Plug 'ericpruitt/tmux.vim', {'rtp': 'vim/'}
Plug 'sudar/vim-arduino-syntax'
"Plug 'aliou/bats.vim'

" Python
Plug 'vim-scripts/indentpython.vim'
Plug 'nvie/vim-flake8'
Plug 'psf/black'

" AWS / CloudFormation
Plug 'speshak/vim-cfn'
Plug 'hashivim/vim-terraform'
call plug#end()

"filetype plugin indent on    " re-enable filetype plugin after Vundle init

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Console UI and text display

"set re=1                           " ??
"set cmdheight=2                     " explicitly set the height of the command line
set laststatus=2                    " always display the status line
set showcmd                         " Show (partial) command in status line
"set number                         " show line numbers
set ruler                           " show current position at bottom
set noerrorbells                    " don't whine
set visualbell t_vb=                " and don't make faces
set lazyredraw                      " don't redraw while in macros
set scrolloff=5                     " keep at least 5 lines around the cursor
set listchars=eol:$,tab:>·,trail:~  " define chars used for EOL, <Tab> and trailing whitespace
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

if has('syntax')
  let python_highlight_all=1
	syntax on                       " enable syntax highlighting
	if &term =~ '256color'          " if 256color is part of our term name
		set t_Co=256                  " enable 256-color mode
		set t_ut=                     " disable background color erase: http://sunaku.github.io/vim-256color-bce.html
	endif

	if &t_Co == 256                  " if 256 color mode is enabled
		set background=dark            " use dark backgrounds
		let g:solarized_termcolors=256 " enable 256 color in solarized theme
		silent! colorscheme solarized  " use solarized theme
	endif
	if &diff                         " if this is vimdiff
		silent! colorscheme apprentice " use the blue colorscheme
	endif
endif

" Enable background transparency
hi Normal guibg=NONE ctermbg=NONE
"hi Normal ctermfg=255 ctermbg=none
"hi NonText ctermfg=250 ctermbg=none


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Indents and tabs

set tabstop=2                " number of columns that <Tab> in file uses
set shiftwidth=2             " number of columns to use for (auto)indent step
set softtabstop=2            " number of columns that <Tab> uses while editing
"set noexpandtab              " don't use spaces when <Tab> is inserted
set expandtab                " only use spaces when <Tab> is inserted
set smarttab                 " use &shiftwidth when inserting tabs
filetype plugin indent on    " load filetype plugins and indent settings


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text editing and searching behavior

set nohlsearch                  " turn off highlighting for searched expressions
set incsearch                   " highlight as we search however
set matchtime=5                 " blink matching chars for .x seconds
set mouse=a                     " try to use a mouse in the console (wimp!)
set ignorecase                  " set case insensitivity
set smartcase                   " unless there's a capital letter
"set completeopt=menu,longest,preview " more autocomplete <Ctrl>-P options
"set nostartofline               " leave my cursor position alone!
set backspace=2                 " equiv to :set backspace=indent,eol,start
set colorcolumn=80
set textwidth=80                " we like 80 columns
set showmatch                   " show matching brackets
set pastetoggle=<F11>           " use <F11> to toggle between paste and nopaste
set formatoptions=crql          " t - autowrap to textwidth
                                " c - autowrap comments to textwidth
                                " r - autoinsert comment leader with <Enter>
                                " q - allow formatting of comments with :gq
                                " l - don't format already long lines
set autochdir                   " cd into dir of file being edited

" Enable folding
set foldmethod=indent
set foldlevel=99

" Enable folding with the spacebar
nnoremap <space> za

" Spell checking
set spell spelllang=en_us
hi clear SpellBad
hi SpellBad cterm=underline ctermfg=red

" Strip trailing whitespace
fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun
command! TrimWhitespace call TrimWhitespace()
command! StripWhitespace call TrimWhitespace()

" Trim whitespace from all file types on write
"autocmd FileType c,cpp,java,php,ruby,python,sh autocmd BufWritePre <buffer> :call TrimWhitespace()
autocmd BufWritePre * :call TrimWhitespace()

" Tune syntasic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Enable additional checkers
let g:syntastic_make_checkers = ['gnumake']
let g:syntastic_json_checkers = ['json_tool']
let g:syntastic_yaml_checkers = ['pyyaml']

" Tweak auto-complete
let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>

" virtualenv support
py3 << EOF
import os
import sys
if 'VIRTUAL_ENV' in os.environ:
  project_base_dir = os.environ['VIRTUAL_ENV']
  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
  execfile(activate_this, dict(__file__=activate_this))
EOF

" Terraform tunables
let g:terraform_fmt_on_save=1
let g:terraform_align=1

" Python tunables
autocmd BufWritePre *.py execute ':Black'
