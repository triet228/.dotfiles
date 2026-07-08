" ------------------------------
" Global settings (all filetypes)
" ------------------------------

" Get the defaults that most users want.
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

augroup cursor_shape
  autocmd!
  autocmd VimEnter,InsertLeave * silent execute "!echo \e[2 q"
  autocmd InsertEnter * silent execute "!echo \e[6 q"
augroup END

" --- COMMON SETTINGS (Both SSH and Local) ---
" Remap delete commands to use black hole register (don't overwrite clipboard)
nnoremap d "_d
nnoremap dd "_dd
nnoremap x "_x
nnoremap cw "_cw
vnoremap d "_d
vnoremap x "_x

let s:is_windows = has('win32') || has('win64')
let s:vim_home = s:is_windows ? '~/vimfiles' : '~/.vim'

if !empty($SSH_CONNECTION) && !s:is_windows
    " --- SSH SESSION SETTINGS ---
    function! Osc52Copy()
        let text = getreg('"')
        let encoded = system('base64 -w 0', text)
        let encoded = substitute(encoded, '\n', '', 'g')
        call writefile(["\e]52;c;" . encoded . "\x07"], '/dev/tty', 'b')
    endfunction

    vnoremap y y:call Osc52Copy()<CR>
    vnoremap <C-x> d:call Osc52Copy()<CR>

    " Paste from system clipboard (requires +clipboard support)
    noremap yy "+yy
    noremap p "+p
    noremap P "+P
else
    " --- LOCAL SESSION SETTINGS ---
    if has('clipboard')
        set clipboard=unnamedplus
    endif

    vnoremap <C-c> y`>
    vnoremap y y`>
    vnoremap <C-x> d

    " Persistent clipboard on exit
    if !s:is_windows && executable('xsel')
        autocmd VimLeave * call system("xsel -ib", getreg('+'))
    endif
endif

" Persistent undo
set undofile
let s:undo_dir = expand(s:vim_home . '/undodir')
if !isdirectory(s:undo_dir)
    call mkdir(s:undo_dir, 'p')
endif
execute 'set undodir=' . fnameescape(s:undo_dir)
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
inoremap <expr> <Tab> strpart(getline('.'), 0, col('.') - 1) =~ '^\s*$' ? "\<Tab>" : "\<C-X><C-N>"

" Tab to 4 space
set tabstop=4
set shiftwidth=4
set expandtab

" Toggle spell check
nnoremap <F5> :set spell!<CR>

" No error sound when hitting boundary
set belloff=all

" Ctrl + S to save file
map <buffer> <C-s> :w <CR>

" Ctrl + a to select all
nnoremap <C-a> ggVG

" Move between visual line
noremap <buffer> j gj
noremap <buffer> k gk
noremap <buffer> 0 g0
noremap <buffer> ^ g^
noremap <buffer> $ g$

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

" Mouse
set mouse=

" ------------------------------
" Commenting shortcut
" ------------------------------
augroup commenting_blocks_of_code
  autocmd!
  autocmd FileType c,cpp,java,scala          let b:comment_leader = '// '
  autocmd FileType sh,ruby,python            let b:comment_leader = '# '
  autocmd FileType conf,fstab,markdown       let b:comment_leader = '# '
  autocmd FileType tex                       let b:comment_leader = '% '
  autocmd FileType mail                      let b:comment_leader = '> '
  autocmd FileType vim                       let b:comment_leader = '" '
augroup END

" cm to comment
noremap <silent> <C-m> :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
" cmm to uncomment
noremap <silent> <C-S-m> :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>

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
  autocmd FileType tex execute 'setlocal complete+=k' . fnameescape(expand(s:vim_home . '/keywords.txt'))

  " tab to accept spell check
  autocmd FileType tex noremap <buffer> <Tab> 1z=lw

  " Ctrl + S to compile Latex
  autocmd FileType tex nnoremap <buffer> <C-s> <Esc> :w \| !tectonic % <CR><BS>
augroup END

" ------------------------------
" Text-specific settings
" ------------------------------
augroup text_settings
  autocmd!

  autocmd FileType text set filetype=markdown
  autocmd FileType text setlocal linebreak
  " autocomplete from common English words
  autocmd FileType text execute 'setlocal complete+=k' . fnameescape(expand(s:vim_home . '/keywords.txt'))
  autocmd FileType text noremap <buffer> <Tab> 1z=
  autocmd FileType text noremap <buffer> j gj
  autocmd FileType text noremap <buffer> k gk
  autocmd FileType text noremap <buffer> 0 g0
  autocmd FileType text noremap <buffer> ^ g^
  autocmd FileType text noremap <buffer> $ g$
augroup END

" ------------------------------
" Python-specific settings
" ------------------------------
augroup python_settings
  autocmd!

  " Limit code at 80 characters length
  " autocmd FileType python set textwidth=78
  " autocmd FileType python match ErrorMsg '\%>78v.\+'

  " Coding shorcut
  autocmd FileType python inoremap ( ()<Left>
  autocmd FileType python inoremap [ []<Left>
  autocmd FileType python inoremap { {}<Left>
  autocmd FileType python inoremap " ""<Left>
  autocmd FileType python inoremap ' ''<Left>
  autocmd FileType python inoremap jk <Right>

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
  " autocmd FileType cpp,c set textwidth=78
  " autocmd FileType cpp,c match ErrorMsg '\%>78v.\+'

  " Coding shorcut
  autocmd FileType cpp,c inoremap ( ()<Left>
  autocmd FileType cpp,c inoremap [ []<Left>
  autocmd FileType cpp,c inoremap { {}<Left>
  autocmd FileType cpp,c inoremap " ""<Left>
  autocmd FileType cpp,c inoremap ' ''<Left>
  autocmd FileType cpp,c inoremap jk <Right>

  " Compile and run C++ code with F5
  if has('win32') || has('win64')
      autocmd FileType cpp,c nnoremap <buffer> <F5> :w <bar> !g++ % -o "%:r.exe" && "%:r.exe" <CR>
  else
      autocmd FileType cpp,c nnoremap <buffer> <F5> :w <bar> !g++ % && ./a.out <CR>
  endif
augroup END






