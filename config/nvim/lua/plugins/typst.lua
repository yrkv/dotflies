vim.pack.add({
  'https://github.com/chomosuke/typst-preview.nvim',
})

typst_preview = require('typst-preview')

typst_preview.setup({
  debug = false,
  partial_rendering = true,
  follow_cursor = false,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    if vim.bo[args.buf].filetype == "typst" then
      vim.bo[args.buf].formatexpr = nil
    end
  end,
})

vim.lsp.config["tinymist"] = {
  cmd = { "/home/yegor/.local/share/nvim/typst-preview/tinymist-linux-x64" },
  filetypes = { "typst" },
  settings = {
    -- ...
  },
}

-- Having LSP enabled breaks `gq` text reflowing :/
-- Couldn't quite figure out why
--vim.lsp.enable('tinymist')
--vim.lsp.inlay_hint.enable(true)

