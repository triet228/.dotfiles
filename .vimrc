" Load Vim defaults with enhancements
source $VIMRUNTIME/vimrc_example.vim

" Always set cursor shape to I-beam (vertical bar)
let &t_SI = "\e[6 q"   " Insert mode
let &t_EI = "\e[6 q"   " Normal mode

" Use system clipboard for copy, cut, paste
vnoremap <C-c> "+y   " Ctrl+c to copy visual selection to clipboard
vnoremap <C-x> "+d   " Ctrl+x to cut visual selection to clipboard
nnoremap <F5> :w<CR>:!tectonic %<CR> 

" Disable creation of swap files
set noswapfile

" Auto-wrap lines at 80 characters
set textwidth=80

" Line numbering
set number
set relativenumber

" Highlight characters beyond 80 columns
match ErrorMsg '\%>80v.\+'

" Disable unwanted LaTeX indenting
autocmd FileType tex setlocal noautoindent nosmartindent nocindent indentexpr=
let g:did_indent_tex = 1

colorscheme torte 




