vim.opt.clipboard = "unnamedplus"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader keys (must be set before lazy)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load plugin specs
require("options")
require("lazy").setup("plugins")
require("autocmds")

-- Auto-start server for inverse search
pcall(function() vim.fn.serverstart("/tmp/nvim-latex") end)
