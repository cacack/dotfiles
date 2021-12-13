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
Plug 'kyazdani42/nvim-web-devicons' " for file icons
" Themes
Plug 'romainl/Apprentice'  " for vimdiff
Plug 'lifepillar/vim-gruvbox8'
"Plug 'altercation/vim-colors-solarized'  " Original doesn't support truecolors
Plug 'ishan9299/nvim-solarized-lua'
Plug 'lifepillar/vim-solarized8'
Plug 'sainnhe/sonokai'
Plug 'arcticicestudio/nord-vim'

" Make it an IDE
Plug 'kyazdani42/nvim-tree.lua'
Plug 'akinsho/bufferline.nvim'
Plug 'scrooloose/nerdtree'            " 
Plug 'editorconfig/editorconfig-vim'  " Project-based editor settings
Plug 'preservim/nerdcommenter'        " code commenter based on file type
Plug 'neomake/neomake'                " Syntax/linting
Plug 'sbdchd/neoformat'               " Formatting
Plug 'neoclide/coc.nvim', {'branch': 'release'}  " LSP

" Languages
"Plug 'nvie/vim-flake8'         " Python
"Plug 'psf/black'               " Python
"Plug 'speshak/vim-cfn'         " CloudFormation
"Plug 'hashivim/vim-terraform'  " Terraform

call plug#end()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Looks
syntax on                      " Turn syntax highlighting on
set background=dark            " use dark backgrounds
if has('termguicolors')
  set termguicolors
endif
let g:gruvbox_italics=1
let g:gruvbox_italicize_strings=1
let g:gruvbox_filetype_hi_groups = 1
let g:gruvbox_plugin_hi_groups = 1
"colorscheme gruvbox8_hard
let g:airline_theme = 'sonokai'
let g:sonokai_transparent_background = 0
"colorscheme sonokai
let g:solarized_italics = 1
let g:solarized_termtrans = 0
"colorscheme solarized  " use solarized theme
colorscheme solarized8  " use solarized theme
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
set hidden  " TextEdit might fail if hidden is not set.
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup
" Give more space for displaying messages.
set cmdheight=2
" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key mappings
let mapleader = ";"                       " Set leader to ;
nnoremap <leader>sv :source $MYVIMRC<CR>  " Map ;sv to reload config

map <C-n> :NERDTreeToggle<CR>             " Toggle NERDTree

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tunables

autocmd FileType python let b:coc_root_patterns = ['.git', '.env', 'venv', '.venv', 'setup.cfg', 'setup.py', 'pyproject.toml', 'pyrightconfig.json']

" Terraform tunables
let g:terraform_fmt_on_save=1
let g:terraform_align=1

" NeoFormat
"let g:neoformat_enabled_python = ['black']

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Bufferline
lua << EOF
require("bufferline").setup{
  options = {
    diagnostics = "coc",
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      local icon = level:match("error") and " " or " "
      return " " .. icon .. count
    end,
    separator_style = "slant",
    offsets = {
      {
        filetype = "NvimTree",
        text = function()
          return vim.fn.getcwd()
        end,
        highlight = "Directory",
        text_align = "left"
      }
    }
  }
}
EOF
" These commands will navigate through buffers in order regardless of which mode you are using
" e.g. if you change the order of buffers :bnext and :bprevious will not respect the custom ordering
nnoremap <silent>b] :BufferLineCycleNext<CR>
nnoremap <silent>b[ :BufferLineCyclePrev<CR>

" These commands will move the current buffer backwards or forwards in the bufferline
"nnoremap <silent><mymap> :BufferLineMoveNext<CR>
"nnoremap <silent><mymap> :BufferLineMovePrev<CR>

" These commands will sort buffers by directory, language, or a custom criteria
nnoremap <silent>be :BufferLineSortByExtension<CR>
nnoremap <silent>bd :BufferLineSortByDirectory<CR>
"nnoremap <silent><mymap> :lua require'bufferline'.sort_buffers_by(function (buf_a, buf_b) return buf_a.id < buf_b.id end)<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tree
lua << EOF
require("nvim-tree").setup {
  open_on_setup       = false,
}
EOF
nnoremap <C-n> :NvimTreeToggle<CR>
nnoremap <leader>r :NvimTreeRefresh<CR>
nnoremap <leader>n :NvimTreeFindFile<CR>
