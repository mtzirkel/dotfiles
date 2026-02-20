-- ~/.config/nvim/lua/plugins/treesitter.lua

-- It MUST be at the beginning of runtimepath. Otherwise the parsers from Neovim itself
-- are loaded that may not be compatible with the queries from the 'nvim-treesitter' plugin.
vim.opt.runtimepath:prepend(vim.fn.stdpath("config") .. "/parsers")

require("nvim-treesitter.configs").setup({
  parser_install_dir = vim.fn.stdpath("config") .. "/parsers",

  ensure_installed = { "c", "lua", "vim", "python", "javascript", "html", "css" }, -- Add your desired languages here

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  -- Add other modules and configurations as needed
})
