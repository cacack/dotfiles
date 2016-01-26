" Heavliy influced by http://stackoverflow.com/a/1639391
" VIM Ref: http://vimdoc.sourceforge.net/htmldoc/quickref.html#option-list

scriptencoding utf-8
set encoding=utf-8

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vundle
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" vim +PluginInstall +qall
set nocompatible                   " break away from old vi compatibility
filetype off                       " required at this point for vundle

set rtp+=~/.vim/bundle/Vundle.vim  " set the runtime path to include Vundle
call vundle#begin()                " initailize Vundle
" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Plugin 'chase/vim-ansible-yaml'
Plugin 'endel/vim-github-colorscheme'
Plugin 'altercation/vim-colors-solarized'
call vundle#end()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Console UI and text display

"set re=1                           " ??
set cmdheight=2                     " explicitly set the height of the command line
set laststatus=2                    " always display the status line
set showcmd                         " Show (partial) command in status line
"set number                         " show line numbers
set ruler                           " show current position at bottom
set noerrorbells                    " don't whine
set visualbell t_vb=                " and don't make faces
set lazyredraw                      " don't redraw while in macros
set scrolloff=5                     " keep at least 5 lines around the cursor
set listchars=eol:$,tab:>·,trail:~  " define chars used for EOL, <Tab> and trailing whitespace

if has('syntax')
	syntax on                        " enable syntax highlighting
	if &term =~ '256color'           " if 256color is part of our term name
		set t_Co=256                  " enable 256-color mode
		set t_ut=                     " disable background color erase: http://sunaku.github.io/vim-256color-bce.html
	endif

	if &t_Co == 256                   " if 256 color mode is enabled
		set background=dark            " use dark backgrounds 
		let g:solarized_termcolors=256 " enable 256 color in solarized theme
		colorscheme solarized          " use solarized theme
	endif
	if &diff                          " if this is vimdiff
		colorscheme blue               " use the blue colorscheme
	endif
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Indents and tabs

set tabstop=3                " number of columns that <Tab> in file uses
set shiftwidth=3             " number of columns to use for (auto)indent step
set softtabstop=3            " number of columns that <Tab> uses while editing
set noexpandtab              " don't use spaces when <Tab> is inserted
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
"set textwidth=80                " we like 80 columns
set showmatch                   " show matching brackets
set pastetoggle=<F11>           " use <F11> to toggle between paste and nopaste
set formatoptions=tcrql         " t - autowrap to textwidth
                                " c - autowrap comments to textwidth
                                " r - autoinsert comment leader with <Enter>
                                " q - allow formatting of comments with :gq
                                " l - don't format already long lines


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Old and unused conf

" Automatic toggle of paste/nopaste modes
" https://coderwall.com/p/if9mda
"function! WrapForTmux(s)
"  if !exists('$TMUX')
"    return a:s
"  endif

"  let tmux_start = "\<Esc>Ptmux;"
"  let tmux_end = "\<Esc>\\"

"  return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
"endfunction

"let &t_SI .= WrapForTmux("\<Esc>[?2004h")
"let &t_EI .= WrapForTmux("\<Esc>[?2004l")

"function! XTermPasteBegin()
"  set pastetoggle=<Esc>[201~
"  set paste
"  return ""
"endfunction

"inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()
