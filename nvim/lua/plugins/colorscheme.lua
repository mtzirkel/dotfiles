return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim", "sainnhe/everforest" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "everforest",
    },
  }
}
