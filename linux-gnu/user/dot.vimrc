" http://vimdoc.sourceforge.net/htmldoc/quickref.html#option-list
"
scriptencoding utf-8
set encoding=utf-8

call pathogen#infect()
syntax on
filetype plugin indent on
"se t_Co=256

" Set theme/color
set background=dark
let g:solarized_termcolors=256
colorscheme solarized

" Set default indentation rules.
set tabstop=3        " How many columns tab uses.
set shiftwidth=3     " How many columns with reindent operations.
set softtabstop=3    " How many columns when in insert mode.
set noexpandtab      " Don't change tabs to spaces.
set smarttab

set listchars=eol:$,tab:>-,trail:~

" Always show the status line.
set laststatus=2

" Automatic toggle of paste/nopaste modes
" https://coderwall.com/p/if9mda
function! WrapForTmux(s)
  if !exists('$TMUX')
    return a:s
  endif

  let tmux_start = "\<Esc>Ptmux;"
  let tmux_end = "\<Esc>\\"

  return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
endfunction

let &t_SI .= WrapForTmux("\<Esc>[?2004h")
let &t_EI .= WrapForTmux("\<Esc>[?2004l")

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

