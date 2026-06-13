local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -- LSP
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",

  -- completion
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",

  -- fuzzy finder
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- treesitter (syntax)
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- file explorer
  "nvim-tree/nvim-tree.lua",

  -- git
  "lewis6991/gitsigns.nvim",

  -- diagnostics panel
  "folke/trouble.nvim",

  -- statusline
  "nvim-lualine/lualine.nvim",
})

require("nvim-tree").setup()
require("gitsigns").setup()
require("trouble").setup()
require("lualine").setup()
