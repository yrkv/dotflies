
vim.pack.add({
    'https://github.com/nvim-tree/nvim-web-devicons',
    'https://github.com/nvim-lualine/lualine.nvim',
})

lualine = require('lualine')

lualine.setup {
  options = { theme  = 'auto' },
  sections = {
    lualine_a = {
      'mode',
    },
    lualine_b = {
      'branch', 'diff',
    },
    lualine_c = {
      {
        'filename',
        newfile_status = true,
        path = 1,
        shorting_target = 9999,
      },
    },
    lualine_x = {
      { 'lsp_status', show_name = false },
      'filetype',
    },
    lualine_y = {
      'progress',
    },
    lualine_z = {
      'location',
    },
  },
}
