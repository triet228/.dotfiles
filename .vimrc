" ------------------------------
" Global settings (all filetypes)
" ------------------------------

" Get the defaults that most users want.
" /usr/share/vim/vim91/defaults.vim
source $VIMRUNTIME/defaults.vim

" No temp file
set noswapfile

" Theme
colorscheme torte 

" Finding files in sub directories :find <file> <tab>
set path+=**

" Cursor beam 
let &t_SI = "\e[6 q"   " I in insert mode
let &t_EI = "\e[2 q"   " Block in normal mode

" Use system clipboard for copy and cut 
set clipboard=unnamedplus

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

" Disable arrow keys
noremap   <Up>    <Nop>
noremap   <Down>  <Nop>
noremap   <Left>  <Nop>
noremap   <Right> <Nop>
inoremap  <Up>    <Nop>
inoremap  <Down>  <Nop>
inoremap  <Left>  <Nop>
inoremap  <Right> <Nop>

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
 
  " spell check
  autocmd FileType tex setlocal spell spelllang=en_us
  
  " tab to autocorrect
  autocmd FileType tex noremap <buffer> <Tab> 1z=

  " move visually instead of by line
  autocmd FileType tex noremap <buffer> j gj
  autocmd FileType tex noremap <buffer> k gk
  autocmd FileType tex noremap <buffer> 0 g0
  autocmd FileType tex noremap <buffer> ^ g^
  autocmd FileType tex noremap <buffer> $ g$

  " Ctrl + S to compile Latex
  autocmd FileType tex inoremap <buffer> <C-s> <Esc> :w \| !tectonic % <CR><BS>a
  autocmd FileType tex nnoremap <buffer> <C-s> <Esc> :w \| !tectonic % <CR><BS>

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


