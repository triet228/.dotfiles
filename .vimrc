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
vnoremap <C-c> y`>
vnoremap y y`>
vnoremap <C-x> d

" Remap delete commands to use black hole register
nnoremap d "_d
nnoremap dd "_dd
nnoremap x "_x
nnoremap cw "_cw

" Persistent undo
set undofile
set undodir=~/.vim/undodir
set undolevels=10000
set undoreload=10000

" Set line number
set number
set relativenumber

" Set highlight when searching
set hlsearch

" Bind <C-h> to remove search highlight
nnoremap <C-h> :nohlsearch<CR>
vnoremap <C-h> :nohlsearch<CR>
inoremap <C-h> <C-o>:nohlsearch<CR>

" Ignore case when searching except when there is uppercase
set ignorecase
set smartcase

" Tab autocomplete
inoremap <expr> <Tab> col('.') > 1 ? "\<C-N>" : "\<Tab>"

" Tab to 4 space
set tabstop=4
set shiftwidth=4
set expandtab

" Toggle spell check 
nnoremap <F5> :set spell!<CR>

" No error sound when hitting boundary
set belloff=all




" Use for training purpose

" Disable arrow keys
noremap   <Up>    <Nop>
noremap   <Down>  <Nop>
noremap   <Left>  <Nop>
noremap   <Right> <Nop>
inoremap  <Up>    <Nop>
inoremap  <Down>  <Nop>
inoremap  <Left>  <Nop>
inoremap  <Right> <Nop>

" Disable mouse
set mouse=




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
  
  " tab to accept spell check
  autocmd filetype tex noremap <buffer> <tab> 1z=lw

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
" Text-specific settings
" ------------------------------
augroup text_settings
  autocmd!

  autocmd FileType text set filetype=markdown
  autocmd FileType text setlocal linebreak
  autocmd FileType text setlocal complete+=k~/.vim/keywords.txt
  autocmd FileType text noremap <buffer> <Tab> 1z=
  autocmd FileType text noremap <buffer> j gj
  autocmd FileType text noremap <buffer> k gk
  autocmd FileType text noremap <buffer> 0 g0
  autocmd FileType text noremap <buffer> ^ g^
  autocmd FileType text noremap <buffer> $ g$
  autocmd FileType text noremap <buffer> <C-s> :w <CR>
augroup END


" ------------------------------
" Python-specific settings
" ------------------------------
augroup python_settings
  autocmd!

  " Limit code at 80 characters length
  autocmd FileType python set textwidth=78
  autocmd FileType python match ErrorMsg '\%>78v.\+'

  " Ctrl S to save file
  autocmd FileType python noremap <buffer> <C-s> :w <CR>

  " Run python with F5 
  " autocmd FileType python noremap <buffer> <C-s> :w! \| !python -i % <CR>
  autocmd FileType python noremap <buffer> <F5> :w! \| !python % <CR> 
augroup END

" ------------------------------
" C++-specific settings
" ------------------------------
augroup cpp_settings
  autocmd!

  " Enable C-style indentation
  autocmd FileType cpp,c setlocal cindent smartindent

  " Limit code at 80 characters length
  autocmd FileType cpp,c set textwidth=78
  autocmd FileType cpp,c match ErrorMsg '\%>78v.\+'

  " Ctrl S to save file
  autocmd FileType cpp,c noremap <buffer> <C-s> :w <CR>

  " Compile and run C++ code with F5
  autocmd FileType cpp,c nnoremap <buffer> <F5> :w <bar> !g++ % && ./a.out <CR>
augroup END




















