set background=dark
filetype plugin on
set tabstop=4
set shiftwidth=4
set ignorecase
set incsearch
set hlsearch
syntax on
set laststatus=2
let &titleold="bash"
autocmd Filetype python setlocal expandtab colorcolumn=120
autocmd Filetype sql setlocal expandtab tabstop=2 shiftwidth=2
autocmd Filetype ruby setlocal expandtab
autocmd Filetype yaml setlocal expandtab tabstop=2 shiftwidth=2 colorcolumn=120
autocmd FileType javascript setlocal expandtab tabstop=2 shiftwidth=2 colorcolumn=120
autocmd FileType htmldjango setlocal expandtab tabstop=2 shiftwidth=2 colorcolumn=120
autocmd FileType html setlocal expandtab tabstop=2 shiftwidth=2 colorcolumn=120
autocmd FileType sh setlocal expandtab tabstop=2 shiftwidth=2 colorcolumn=120
autocmd FileType css setlocal expandtab tabstop=2 shiftwidth=2 colorcolumn=120
autocmd FileType markdown setlocal expandtab tabstop=2 shiftwidth=2 colorcolumn=120

"Note: tmux should be set to use TERM=screen-256color, as xterm-256color does
"not render correctly.
function! SetTermTitle(title)
  let &titlestring = a:title
  if &term == "screen" || &term == "screen-256color"
    set t_ts=k
    set t_fs=\
  endif
  if &term == "screen" || &term == "screen-256color" || &term == "xterm" || &term == "xterm-256color"
    "set title
  endif
endfunction
autocmd BufEnter * :call SetTermTitle(expand("%:t"))

"Note 1: The "^[" special char is achieved by using "Ctrl-V Esc" in insert mode.
"Note 2: For some reason tmux doesn't allow vim to use the <F4> and <F5> key
"aliases directly. To see the actual codes inside tmux, run cat and hit the keys.
nnoremap [14~ <Esc>:N<CR>
nnoremap [15~ <Esc>:n<CR>

set statusline+=%#warningmsg#
set statusline+=%*
set statusline+=%l
