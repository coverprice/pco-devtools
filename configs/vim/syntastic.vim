"Syntastic settings (see https://github.com/vim-syntastic/syntastic )
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set statusline+=%l

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_sh_checkers = ['shellcheck']
let g:syntastic_javascript_checkers = ['eslint']
let b:syntastic_javascript_eslint_exec = system('npm-which babel-eslint')
