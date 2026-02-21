-- Override LazyVim's treesitter config with our preferred languages
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "c",
      "css",
      "html",
      "javascript",
      "lua",
      "python",
      "vim",
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
  },
}
