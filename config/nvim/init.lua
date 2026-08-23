
-- keep minimal config as vimscript -- allows me to use it for vim too
vim.cmd('source ~/.config/vim/vimrc')

require('plugins.lualine')
require('plugins.gitsigns')
require('plugins.sonokai')


vim.cmd([[
let g:python_indent = {}
let g:python_indent.open_paren = 'shiftwidth()'
let g:python_indent.closed_paren_align_last_line = v:false
]])

vim.api.nvim_create_autocmd('FileType', {
  pattern = {'c', 'lua', 'python', },
  callback = function() vim.treesitter.start() end,
})


