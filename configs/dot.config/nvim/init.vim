scriptencoding utf-8
set encoding=utf-8    " Set default encoding to UTF-8
set nocompatible      " break away from old vi compatibility

" Install vim-plug automatically
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-plug
call plug#begin('~/.local/share/nvim/plugged')

" Looks
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Themes
Plug 'romainl/Apprentice'  " for vimdiff
Plug 'lifepillar/vim-gruvbox8'
Plug 'altercation/vim-colors-solarized'
Plug 'sainnhe/sonokai'
Plug 'arcticicestudio/nord-vim'

" Make it an IDE
Plug 'scrooloose/nerdtree'            " 
Plug 'editorconfig/editorconfig-vim'  " Project-based editor settings
Plug 'preservim/nerdcommenter'        " code commenter based on file type
"Plug 'airblade/vim-gitgutter'         " git changes
Plug 'neomake/neomake'                " Syntax/linting
Plug 'sbdchd/neoformat'               " Formatting

" COC and extensions -- provides autocompletion
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'pappasam/coc-jedi', { 'do': 'yarn install --frozen-lockfile && yarn build', 'branch': 'main' }  " Python
Plug 'neoclide/coc-yaml', { 'do': 'yarn install --frozen-lockfile && yarn build', 'branch': 'master' }  " YAML
Plug 'joenye/coc-cfn-lint', { 'do': 'yarn install --frozen-lockfile && yarn build', 'branch': 'master' }  " cfn-lint

" Languages
Plug 'nvie/vim-flake8'         " Python
Plug 'psf/black'               " Python
Plug 'speshak/vim-cfn'         " CloudFormation
Plug 'hashivim/vim-terraform'  " Terraform

call plug#end()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Looks
syntax on
set background=dark            " use dark backgrounds
if has('termguicolors')
  set termguicolors
endif
let g:solarized_termcolors=256 " enable 256 color in solarized theme
let g:gruvbox_italics=1
let g:gruvbox_italicize_strings=1
let g:gruvbox_filetype_hi_groups = 1
let g:gruvbox_plugin_hi_groups = 1
"colorscheme solarized  " use solarized theme
"colorscheme gruvbox8_hard
colorscheme sonokai
let g:airline_theme = 'sonokai'
let g:sonokai_transparent_background = 1
"colorscheme nord
if &diff                           " if this is vimdiff
	silent! colorscheme apprentice " use a specific colorscheme
endif

let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Options
set showmatch               " show matching
set ignorecase              " case insensitive
set mouse=v                 " middle-click paste with
set hlsearch                " highlight search
set incsearch               " incremental search
set tabstop=2               " number of columns occupied by a tab
set softtabstop=2           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=2            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
set cc=80                   " set an 80 column border for good coding style
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
filetype plugin on
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
" set spell                 " enable spell check (may need to download language package)
" " set noswapfile            " disable creating swap file
" " set backupdir=~/.cache/vim " Directory to store backup files.


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key mappings
let mapleader = ";"                       " Set leader to ;
nnoremap <leader>sv :source $MYVIMRC<CR>  " Map ;sv to reload config

map <C-n> :NERDTreeToggle<CR>             " Toggle NERDTree

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tunables

" Terraform tunables
let g:terraform_fmt_on_save=1
let g:terraform_align=1

" NeoFormat
let g:neoformat_enabled_python = ['black']
