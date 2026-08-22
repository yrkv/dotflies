
" synchronize y/p with system clipboard, as well as across nvim instances
" requires some sort of clipboard management installed to work
" on arch with wayland, wl-clipboard does the job
set clipboard=unnamedplus
set modeline

" for most unrecognized files, I tend to prefer 2-space tabs.
set tabstop=2
set shiftwidth=2

set expandtab
set smartindent
" vim.opt.textwidth = 80

set number
set scrolloff=5
set lazyredraw

set mouse=

" When editing a file, always jump to the last known cursor position.
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif


