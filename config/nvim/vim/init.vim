set number
set ruler

" Set tabs to be 2 spaces wide by default
set tabstop=2
set shiftwidth=2

set smartindent
set expandtab

" Highlight search results and start before submitting
set hlsearch
set incsearch

" Disable mouse
set mouse=

" Keep lines visible at the top/bottom of screen when scrolling
set scrolloff=5

" Synchronize y/p with system clipboard, as well as across nvim instances
" requires some sort of clipboard management installed to work.
" On arch with wayland, wl-clipboard does the job
set clipboard=unnamedplus

" Allow vim settings in comments at start/end of file
set modeline

" Make n and N also center the next search result on the screen
nmap n nzz
nmap N Nzz

" Show trailing spaces
set list
set listchars=trail:·

" Flash on the screen instead of making the bell sound
set noerrorbells
set visualbell

filetype plugin indent on
syntax on

" When editing a file, always jump to the last known cursor position.
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif

autocmd FileType make setlocal noexpandtab softtabstop=0

