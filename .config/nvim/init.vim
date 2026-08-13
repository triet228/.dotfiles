set noswapfile
set autoread
augroup auto_reload_files
  autocmd!
  autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * checktime
augroup END

colorscheme torte
set path+=**
set clipboard=unnamedplus

nnoremap d "_d
nnoremap dd "_dd
nnoremap x "_x
nnoremap cw "_cw
vnoremap d "_d
vnoremap x "_x
vnoremap <C-c> y`>
vnoremap y y`>
vnoremap <C-x> d

set undofile
let s:undo_dir = stdpath('data') . '/undo'
if !isdirectory(s:undo_dir)
  call mkdir(s:undo_dir, 'p')
endif
execute 'set undodir=' . fnameescape(s:undo_dir)
set undolevels=10000
set undoreload=10000

set number
set relativenumber
set hlsearch
nnoremap <C-h> :nohlsearch<CR>
vnoremap <C-h> :nohlsearch<CR>
inoremap <C-h> <C-o>:nohlsearch<CR>
set ignorecase
set smartcase

inoremap <expr> <Tab> strpart(getline('.'), 0, col('.') - 1) =~ '^\s*$' ? "\<Tab>" : "\<C-X>\<C-N>"
set tabstop=4
set shiftwidth=4
set expandtab
nnoremap <F5> :set spell!<CR>
set belloff=all
map <buffer> <C-s> :w <CR>
nnoremap <C-a> ggVG
noremap <buffer> j gj
noremap <buffer> k gk
noremap <buffer> 0 g0
noremap <buffer> ^ g^
noremap <buffer> $ g$
noremap   <Up>    <Nop>
noremap   <Down>  <Nop>
noremap   <Left>  <Nop>
noremap   <Right> <Nop>
inoremap  <Up>    <Nop>
inoremap  <Down>  <Nop>
inoremap  <Left>  <Nop>
inoremap  <Right> <Nop>
set mouse=

augroup commenting_blocks_of_code
  autocmd!
  autocmd FileType c,cpp,java,scala          let b:comment_leader = '// '
  autocmd FileType sh,ruby,python,ps1        let b:comment_leader = '# '
  autocmd FileType conf,fstab,markdown       let b:comment_leader = '# '
  autocmd FileType tex                       let b:comment_leader = '% '
  autocmd FileType mail                      let b:comment_leader = '> '
  autocmd FileType vim                       let b:comment_leader = '" '
augroup END
nnoremap <silent> <C-m> :<C-B>silent <C-E>s/^/<C-R>=escape(get(b:, 'comment_leader', '# '),'\/')<CR>/<CR>:nohlsearch<CR>
nnoremap <silent> <C-S-m> :<C-B>silent <C-E>s/^\V<C-R>=escape(get(b:, 'comment_leader', '# '),'\/')<CR>//e<CR>:nohlsearch<CR>

augroup latex_settings
  autocmd!
  autocmd FileType tex setlocal linebreak
  autocmd FileType tex setlocal noautoindent nosmartindent nocindent indentexpr=
  autocmd FileType tex setlocal complete+=k~/.vim/keywords.txt
  autocmd FileType tex noremap <buffer> <tab> 1z=lw
augroup END

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
augroup END

augroup python_settings
  autocmd!
  autocmd FileType python inoremap ( ()<Left>
  autocmd FileType python inoremap [ []<Left>
  autocmd FileType python inoremap { {}<Left>
  autocmd FileType python inoremap " ""<Left>
  autocmd FileType python inoremap ' ''<Left>
  autocmd FileType python inoremap jk <Right>
  autocmd FileType python noremap <buffer> <F5> :w! \| !python % <CR>
augroup END

augroup cpp_settings
  autocmd!
  autocmd FileType cpp,c setlocal cindent smartindent
  autocmd FileType cpp,c inoremap ( ()<Left>
  autocmd FileType cpp,c inoremap [ []<Left>
  autocmd FileType cpp,c inoremap { {}<Left>
  autocmd FileType cpp,c inoremap " ""<Left>
  autocmd FileType cpp,c inoremap ' ''<Left>
  autocmd FileType cpp,c inoremap jk <Right>
  autocmd FileType cpp,c nnoremap <buffer> <F5> :w <bar> !g++ % && .\a.exe <CR>
augroup END
