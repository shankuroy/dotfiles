-- requires neovim version 0.12 or above
local g, o, k = vim.g, vim.opt, vim.keymap.set

-- globals
g.mapleader = ' ' -- set leader key to space

-- plugins
vim.pack.add({
  'https://codeberg.org/andyg/leap.nvim',           -- general purpose motions
  'https://github.com/ahmedkhalf/project.nvim',     -- auto-detect project root
  'https://github.com/folke/tokyonight.nvim',       -- theme
  'https://github.com/folke/snacks.nvim',           -- misc plugins
  'https://github.com/lewis6991/gitsigns.nvim',     -- git info
  'https://github.com/nvim-lualine/lualine.nvim',   -- nicer status line
  'https://github.com/nvim-mini/mini.nvim',         -- misc plugins
  'https://github.com/nvim-tree/nvim-web-devicons', -- icons
})

-- plugin config
-- -- gitsigns.nvim
local gitsigns = require('gitsigns')
-- -- lualine
require('lualine').setup()
-- -- mini.nvim
require('mini.surround').setup()
require('mini.trailspace').setup()
-- -- project.nvim
require('project_nvim').setup()
-- -- snacks.nvim -- see examples at: https://tduyng.com/blog/vim-pack-and-snacks/
local Snacks = require("snacks")
Snacks.setup({
  explorer = {
    enabled = true,
    replace_netrw = true,
  },
  picker = {
    enabled = true,
    hidden = true,
    sources = {
      explorer = {
        layout = {
          layout = {
            position = "right",
          },
        },
      },
    },
  },
})

-- keymaps
-- -- clipboard
k({'n', 'v'}, '<leader>p', '"+p',                                   { desc = 'paste from system clipboard' })
k({'n', 'v'}, '<leader>P', '"+P',                                   { desc = 'paste before from system clipboard' })
k({'n', 'v'}, '<leader>y', '"+y',                                   { desc = 'yank to system clipboard' })
-- -- buffer
k('n', '<leader>bb',  '<C-^>',                                      { desc = 'switch to previous buffer' })
-- -- fuzzy find
k('n', '<leader>fb',  Snacks.picker.buffers,                        { desc = 'find buffers' })
k('n', '<leader>ff',  Snacks.picker.files,                          { desc = 'find files' })
k('n', '<leader>fg',  Snacks.picker.git_files,                      { desc = 'find git files' })
k('n', '<leader>fk',  Snacks.picker.keymaps,                        { desc = 'find keymaps' })
k('n', '<leader>f/',  Snacks.picker.grep,                           { desc = '/ grep files' })
-- -- git
k('n', '<leader>gb',  gitsigns.blame_line,                          { desc = 'git blame line' })
k('n', '<leader>gd',  gitsigns.preview_hunk_inline,                 { desc = 'git diff inline' })
k('n', '<leader>gg',  function() Snacks.lazygit() end,              { desc = 'lazygit' })
-- -- visual
k('n', '<leader>e',   function() Snacks.explorer() end,             { desc = 'file explorer' })
k('n', '<leader>tw',  ':set wrap!<CR>',                             { desc = 'toggle line wrap' })
-- -- leap.nvim
k({'n', 'x', 'o'}, '<leader>s', '<Plug>(leap)',                     { desc = 'search with leap.nvim' })


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
vim.cmd [[colorscheme tokyonight-night]]

