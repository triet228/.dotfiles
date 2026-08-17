" ============================================================
" Plugins
" ============================================================

call plug#begin(stdpath('data') . '/plugged')

Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'saghen/blink.cmp', { 'tag': 'v1.*' }
Plug 'windwp/nvim-autopairs'
Plug 'tpope/vim-commentary'

call plug#end()


" ============================================================
" Filetype / syntax / indentation
" ============================================================

syntax on
filetype plugin indent on


" ============================================================
" Basic keybindings
" ============================================================

" Ctrl + A to select everything
nnoremap <C-a> ggVG
nnoremap <C-s> :w<CR>
vnoremap <C-X> "+d

" Normal mode Tab = Pyright/LSP code actions
nnoremap <Tab> :lua vim.lsp.buf.code_action()<CR>

" F5 to run Python file
autocmd FileType python nnoremap <buffer> <F5> :w<CR>:execute "tabnew \| terminal python " . shellescape(expand('%'))<CR> \| G

" Turn off search highlight
nnoremap <C-h> :nohlsearch<CR>


" ============================================================
" Comments
" ============================================================

" Ctrl-M = toggle comment
nmap <C-m> gcc
vmap <C-m> gc


" ============================================================
" Display
" ============================================================

set relativenumber
set number
set laststatus=0
colorscheme torte


" ============================================================
" Soft-wrap navigation
" ============================================================

nnoremap j gj
nnoremap k gk
nnoremap 0 g0
nnoremap ^ g^
nnoremap $ g$
vnoremap j gj
vnoremap k gk
vnoremap 0 g0
vnoremap ^ g^
vnoremap $ g$


" ============================================================
" Clipboard
" ============================================================

set clipboard=unnamedplus


" ============================================================
" Delete/change without overwriting yank
" ============================================================

nnoremap x "_x
nnoremap X "_X
vnoremap x "_x
vnoremap X "_X

nnoremap d "_d
nnoremap D "_D
vnoremap d "_d

nnoremap s "_s
nnoremap S "_S
vnoremap s "_s


" ============================================================
" Tab / indentation
" ============================================================

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent

" Visual mode Tab / Shift + Tab = indent selected block
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv


" ============================================================
" LSP + completion
" ============================================================

lua << EOF

local ok_pairs, autopairs = pcall(require, "nvim-autopairs")

if ok_pairs then
    autopairs.setup({})
end

local ok_mason, mason = pcall(require, "mason")
local ok_mason_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
local ok_lspconfig = pcall(require, "lspconfig")

if not (ok_mason and ok_mason_lspconfig and ok_lspconfig) then
    return
end

mason.setup()

mason_lspconfig.setup({
    ensure_installed = {
        "pyright",
    },
})

vim.diagnostic.config({
    signs = false,
    underline = false,
    virtual_text = false,
    update_in_insert = false,
})

local ok, blink = pcall(require, "blink.cmp")

if ok then
    blink.setup({
        keymap = {
            preset = "none",

            ["<Tab>"] = {
                "accept",
                "fallback",
            },

            ["<C-n>"] = {
                "select_next",
                "fallback",
            },
        },

        sources = {
            default = {
                "lsp",
                "buffer",
                "path",
            },
        },

        completion = {
            menu = {
                auto_show = true,
            },
        },

        fuzzy = {
            implementation = "prefer_rust",
        },
    })
end

vim.lsp.config("pyright", {
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "off",
                diagnosticMode = "openFilesOnly",
            },
        },
    },
})
vim.lsp.enable("pyright")


EOF


" ============================================================
" Line endings
" ============================================================

set fileformats=unix,dos
set fileformat=unix
augroup unix_line_endings
  autocmd!
  autocmd BufWritePre * setlocal fileformat=unix
augroup END


" ============================================================
" Cursor / undo / autosave
" ============================================================

" Restore cursor at last position
augroup RestoreCursor
    autocmd!
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif
augroup END

set undofile

" Autosave when leaving insert mode or changing text
autocmd InsertLeave,TextChanged * if &modifiable && !&readonly | silent! update | endif

" Automatically reload files changed outside Vim
set autoread
