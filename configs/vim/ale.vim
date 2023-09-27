" Vim ALE https://github.com/dense-analysis/ale

" Stops warnings/errors from appearing next to their location as virtual text
let g:ale_virtualtext_cursor = 'disabled'

" Stops realtime linting (which can be distracting). Only lints on save.
let g:ale_lint_on_text_changed = 'never'

" Stops linting when Insert mode is exited.
let g:ale_lint_on_insert_leave = 0

" When errors are detected, open the window at the bottom to list them all so
" they can be navigated.
let g:ale_open_list = 1

" Makes ALEError highlighting legible when highlighting strings in dark mode
" (default is to have red bg with magenta text, which has no contrast)
highlight SpellBad term=reverse ctermbg=12 gui=undercurl guisp=Red

" Ctrl-k / Ctrl-j to move to prev/next error.
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
