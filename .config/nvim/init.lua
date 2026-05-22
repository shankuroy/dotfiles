-- requires neovim version 0.12 or above

-- leader key
vim.g.mapleader = ' '


--
-- gitsigns: git info in the gutter
vim.pack.add({'https://github.com/lewis6991/gitsigns.nvim'})
local gitsigns = require('gitsigns')
vim.keymap.set('n', '<leader>gb', gitsigns.blame_line,          { desc = 'git blame line' })
vim.keymap.set('n', '<leader>gd', gitsigns.preview_hunk_inline, { desc = 'git diff inline' })


--
-- leap: fast buffer navigation
vim.pack.add({'https://codeberg.org/andyg/leap.nvim'})
vim.keymap.set({'n', 'x', 'o'}, '<leader>s', '<Plug>(leap)',    { desc = 'search with leap.nvim' })


--
-- lualine: nicer status line
vim.pack.add({
  'https://github.com/nvim-lualine/lualine.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons'
})
require('lualine').setup()


--
-- mini: misc plugins
vim.pack.add({'https://github.com/nvim-mini/mini.nvim'})
require('mini.surround').setup()
require('mini.trailspace').setup()


--
-- project: auto-detect project root
vim.pack.add({'https://github.com/ahmedkhalf/project.nvim'})
require('project_nvim').setup()


--
-- snacks.nvim -- see examples at: https://tduyng.com/blog/vim-pack-and-snacks/
vim.pack.add({'https://github.com/folke/snacks.nvim'})
local Snacks = require("snacks")
Snacks.setup({
  explorer = {
    enabled = true,
    replace_netrw = true,
    trash = true,
  },
  gitbrowse = {
    open = function(url)
      local profile_stripped = url:gsub("github.com%-%w+", "github.com")
      vim.ui.open(profile_stripped)
    end
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

vim.keymap.set('n', '<leader>fb', Snacks.picker.buffers,              { desc = 'find buffers' })
vim.keymap.set('n', '<leader>ff', Snacks.picker.files,                { desc = 'find files' })
vim.keymap.set('n', '<leader>fg', Snacks.picker.git_files,            { desc = 'find git files' })
vim.keymap.set('n', '<leader>fk', Snacks.picker.keymaps,              { desc = 'find keymaps' })
vim.keymap.set('n', '<leader>f/', Snacks.picker.grep,                 { desc = '/ grep files' })
vim.keymap.set('n', '<leader>gx', function() Snacks.gitbrowse() end,  { desc = 'open line in browser' })
vim.keymap.set('n', '<leader>gg', function() Snacks.lazygit() end,    { desc = 'lazygit' })
vim.keymap.set('n', '<leader>e',  function() Snacks.explorer() end,   { desc = 'file explorer' })


--
-- colorscheme
vim.pack.add({'https://github.com/folke/tokyonight.nvim'})
vim.cmd [[colorscheme tokyonight-night]]


--
-- keymaps
vim.keymap.set({'n', 'v'}, '<leader>p',  '"+p',                       { desc = 'paste from system clipboard' })
vim.keymap.set({'n', 'v'}, '<leader>P',  '"+P',                       { desc = 'paste before from system clipboard' })
vim.keymap.set({'n', 'v'}, '<leader>y',  '"+y',                       { desc = 'yank to system clipboard' })
vim.keymap.set({'n'},      '<leader>bb', '<C-^>',                     { desc = 'switch to previous buffer' })
vim.keymap.set({'n'},      '<leader>tw', ':set wrap!<CR>',            { desc = 'toggle line wrap' })
vim.keymap.set({'v'},      '>',          '>gv',                       { desc = 'continuous indent' })
vim.keymap.set({'v'},      '<',          '<gv',                       { desc = 'continuous dedent' })


--
-- options
vim.opt.autoindent = true       -- copy indent from current line to next
vim.opt.breakindent = true      -- indent wrapped lines to match line start
vim.opt.cursorline = true       -- highlight current line
vim.opt.expandtab = true        -- use spaces instead of tabs
vim.opt.ignorecase = true       -- ignore case while searching
vim.opt.number = true           -- show line number
vim.opt.relativenumber = true   -- show relative line numbers
vim.opt.scrolloff = 8           -- start scrolling page this many lines vertically
vim.opt.shiftwidth = 2          -- number of cols that make up one level of indentation
vim.opt.sidescrolloff = 8       -- start scrolling page this many chars horizontally
vim.opt.signcolumn = 'yes'      -- always show sign column
vim.opt.smartcase = true        -- don't ignore case when search has uppercase
vim.opt.softtabstop = -1        -- -1 means to use shiftwidth for the number of cols between two soft tab stops
vim.opt.splitbelow = true       -- horizontal splits will be below
vim.opt.splitright = true       -- vertical splits will be to the right
vim.opt.termguicolors = true    -- enable 24-bit colors
vim.opt.virtualedit = 'block'   -- allow going past the end of the line in visual block mode
vim.opt.wrap = false            -- don't wrap lines

