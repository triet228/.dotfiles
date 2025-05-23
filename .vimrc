" ------------------------------
" Global settings (all filetypes)
" ------------------------------

" Enable syntax
syntax enable

" Theme
colorscheme torte 

" Finding files in sub directories :find <file> <tab>
set path+=**

" Autocomplete in insert mode
" Autocomplete same file: Ctrl + P
" Autocomplete directory: Ctrl + x then Ctrl + f

" Cursor beam 
let &t_SI = "\e[6 q"   " I in insert mode
let &t_EI = "\e[2 q"   " Block in normal mode

" Use system clipboard for copy and cut 
vnoremap <C-c> "+y   " Ctrl+c to copy visual selection to clipboard
vnoremap <C-x> "+d   " Ctrl+x to cut visual selection to clipboard

" Disable swap files
set noswapfile

" Set line number
set number
set relativenumber

" ------------------------------
" LaTeX-specific settings
" ------------------------------
augroup latex_settings
  autocmd!
  
  " line break at words instead of char
  autocmd FileType tex setlocal linebreak

  " move visually instead of by line
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

  " Ctrl + S to compile Latex
  nnoremap <C-s> <Esc>:w<CR>:!tectonic % <CR> <CR>
  inoremap <C-s> <Esc>:w<CR>:!tectonic % <CR> <CR>
  
augroup END

" ------------------------------
" Python-specific settings
" ------------------------------
augroup python_settings
  autocmd!

  " Limit code at 80 characters length
  autocmd FileType python set textwidth=78
  autocmd FileType python match ErrorMsg '\%>78v.\+'

augroup END

 
