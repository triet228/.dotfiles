" ------------------------------
" Global settings (all filetypes)
" ------------------------------

" Get the defaults that most users want.
" /usr/share/vim/vim91/defaults.vim
source $VIMRUNTIME/defaults.vim

" Theme
colorscheme torte 

" Finding files in sub directories :find <file> <tab>
set path+=**

" Cursor beam 
let &t_SI = "\e[6 q"   " I in insert mode
let &t_EI = "\e[2 q"   " Block in normal mode

" Use system clipboard for copy and cut 
vnoremap <C-c> "+y   " Ctrl+c to copy visual selection to clipboard
vnoremap <C-x> "+d   " Ctrl+x to cut visual selection to clipboard

" Set line number
set number
set relativenumber

" Ignore case when searching except when there is uppercase
set ignorecase
set smartcase

" Tab autocomplete
inoremap <expr> <Tab> col('.') > 1 ? "\<C-N>" : "\<Tab>"

" Tab to 4 space
set tabstop=4
set shiftwidth=4

" ------------------------------
" LaTeX-specific settings
" ------------------------------
augroup latex_settings
  autocmd!
  
  " line break at words instead of char
  autocmd FileType tex setlocal linebreak

  " completely disable auto indentation for LaTeX
  autocmd FileType tex setlocal noautoindent nosmartindent nocindent indentexpr=

  " autocomplete from common English words
  autocmd FileType tex setlocal complete+=k~/.vim/keywords.txt
  
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
  autocmd FileType tex nnoremap <C-s> <Esc>:w<CR>:!tectonic % <CR> <CR>
  autocmd FileType tex inoremap <C-s> <Esc>:w<CR>:!tectonic % <CR> <CR> 

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


