-- requires neovim version 0.12 or above
local g, o, k = vim.g, vim.opt, vim.keymap.set

-- globals
g.mapleader = ' ' -- set leader key to space

-- plugins
vim.pack.add({
  'https://github.com/ahmedkhalf/project.nvim',     -- auto-detect project root
  'https://github.com/catppuccin/nvim',             -- theme
  'https://github.com/ibhagwan/fzf-lua',            -- fuzzy finder
  'https://github.com/lewis6991/gitsigns.nvim',     -- git info
  'https://github.com/nvim-lualine/lualine.nvim',   -- nicer status line
  'https://github.com/nvim-mini/mini.nvim',         -- misc plugins
  'https://github.com/nvim-tree/nvim-web-devicons', -- icons
})

-- plugin config
-- -- fzf-lua
local fzflua = require('fzf-lua')
fzflua.setup({'borderless'})
-- -- gitsigns.nvim
local gitsigns = require('gitsigns')
-- -- lualine
require('lualine').setup()
-- -- mini.nvim
require('mini.ai').setup()
require('mini.pairs').setup()
require('mini.surround').setup()
-- -- project.nvim
require('project_nvim').setup()

-- keymaps
-- -- clipboard
k({'n', 'v'}, '<leader>P', '"+P', { desc = '[P]aste before from system clipboard' })
k({'n', 'v'}, '<leader>p', '"+p', { desc = '[p]aste from system clipboard' })
k({'n', 'v'}, '<leader>y', '"+y', { desc = '[y]ank to system clipboard' })
-- -- buffer
k('n', '<leader>bb', '<C-^>', { desc = '[b]uffer [b]efore' })
k('n', '<leader>bf', fzflua.buffers, { desc = '[b]uffer [f]ind' })
-- -- fuzzy find
k('n' ,'<leader>fb', fzflua.builtin, { desc = '[f]ind [b]uiltins' })
k('n', '<leader>ff', fzflua.files, { desc = '[f]ind [f]iles' })
k('n', '<leader>fg', fzflua.live_grep, { desc = '[f]ind [g]rep' })
-- -- git
k('n', '<leader>gb', gitsigns.blame_line, { desc = '[g]it [b]lame line' })
k('n', '<leader>gd', gitsigns.preview_hunk_inline, { desc = '[g]it [d]iff inline' })

-- options
o.autoindent = true       -- copy indent from current line to next
o.breakindent = true      -- indent wrapped lines to match line start
o.cursorline = true       -- highlight current line
o.expandtab = true        -- use spaces instead of tabs
o.ignorecase = true       -- ignore case while searching
o.number = true           -- show line number
o.relativenumber = true   -- show relative line numbers
o.scrolloff = 8           -- start scrolling page this many lines vertically
o.shiftwidth = 2          -- number of cols that make up one level of indentation
o.sidescrolloff = 8       -- start scrolling page this many chars horizontally
o.signcolumn = 'yes'      -- always show sign column
o.smartcase = true        -- don't ignore case when search has uppercase
o.softtabstop = -1        -- -1 means to use shiftwidth for the number of cols between two soft tab stops
o.splitbelow = true       -- horizontal splits will be below
o.splitright = true       -- vertical splits will be to the right
o.termguicolors = true    -- enable 24-bit colors
o.virtualedit = 'block'   -- allow going past the end of the line in visual block mode
o.wrap = false            -- don't wrap lines

-- colorscheme
vim.cmd [[colorscheme catppuccin-mocha]]

