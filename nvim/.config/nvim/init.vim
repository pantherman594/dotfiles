set nocompatible
filetype off

call plug#begin()

" small changes
Plug 'tpope/vim-sensible'

" surround selectors
Plug 'tpope/vim-surround'

" linting
" Plug 'vim-syntastic/syntastic'
Plug 'w0rp/ale'

Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'

" airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" js and jsx syntax highlighting
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'

" typescript
Plug 'leafgarland/typescript-vim'
Plug 'Quramy/tsuquyomi'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'mhartington/nvim-typescript', {'do': './install.sh'}
Plug 'ianks/vim-tsx', { 'for': 'typescript.tsx' }

" completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/denite.nvim'
let g:deoplete#enable_at_startup = 1

" LaTeX
Plug 'lervag/vimtex'

call plug#end()
filetype plugin indent on
" show existing tab with 2 spaces width
set tabstop=2
" when indenting with '>', use 2 spaces width
set shiftwidth=2
" On pressing tab, insert 2 spaces
set expandtab

set number

" Map shift-tab to reverse tab
inoremap <S-Tab> <C-d>

" Map gb to list buffers
map gb :ls<CR>:b<Space>
" map g[n, p, d] to go to next, previous, or delete buffer
map gn :bn<CR>
map gp :bp<CR>
map gd :bd<CR>

" syntastic settings
" set statusline +=%#warningmsg#
" set statusline +=%{SyntasticStatuslineFlag()}
" set statusline +=%*
" 
" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0
" 
" let g:syntastic_javascript_checkers = ['eslint']
" let g:syntastic_javascript_eslint_exe = '$(npm bin)/eslint'

" ale settings
let g:ale_lint_on_text_changed = 'never'
let g:airline#extensions#ale#enabled = 1
let g:ale_fixers = {
\ '*': ['remove_trailing_lines', 'trim_whitespace'],
\ 'javascript': ['eslint'],
\ 'latex': ['lacheck']
\}

" airline settings
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='atomic'

let g:tex_flavor = 'latex'

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" enable syntax highlighting
syntax enable

set encoding=utf-8
" enabling hidden allows you to switch buffers without saving
set hidden
" highlight if longer than 80 characters
set colorcolumn=100
highlight ColorColumn ctermbg=magenta guibg=magenta

" Make double-esc clear search highlights
nnoremap <silent> <Esc><Esc> <Esc>:nohlsearch<CR><Esc>
