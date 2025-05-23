" Load Vim defaults with enhancements
" /usr/share/vim/vim91/vimrc_example.vim
source $VIMRUNTIME/vimrc_example.vim

" I-beam in insert mode and block beam in normal mode
let &t_SI = "\e[6 q"   " Insert mode
let &t_EI = "\e[2 q"   " Normal mode

" Use system clipboard for copy, cut, paste
vnoremap <C-c> "+y   " Ctrl+c to copy visual selection to clipboard
vnoremap <C-x> "+d   " Ctrl+x to cut visual selection to clipboard
nnoremap <F5> <Esc>:w<CR>:!tectonic % <CR> <CR>
inoremap <F5> <Esc>:w<CR>:!tectonic % <CR> <CR>

" Disable creation of swap files
set noswapfile

" Theme
colorscheme torte 



" ------------------------------
" Global settings (all filetypes)
" ------------------------------
set textwidth=78
set number
set relativenumber
match ErrorMsg '\%>78v.\+'

" ------------------------------
" LaTeX-specific settings
" ------------------------------
augroup latex_settings
  autocmd!
  autocmd FileType tex setlocal linebreak
  autocmd FileType tex nnoremap <buffer> j gj
  autocmd FileType tex nnoremap <buffer> k gk
  autocmd FileType tex nnoremap <buffer> 0 g0
  autocmd FileType tex nnoremap <buffer> ^ g^
  autocmd FileType tex nnoremap <buffer> $ g$
  autocmd FileType tex vnoremap <buffer> j gj
  autocmd FileType tex vnoremap <buffer> k gk
  autocmd FileType tex vnoremap <buffer> 0 g0
  autocmd FileType tex vnoremap <buffer> ^ g^
  autocmd FileType tex vnoremap <buffer> $ g$
  " Optional: disable LaTeX indenting
  " autocmd FileType tex setlocal noautoindent nosmartindent nocindent indentexpr=
  " let g:did_indent_tex = 1
augroup END


