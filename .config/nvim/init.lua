-- requires neovim version 0.12 or above

-- leader key
vim.g.mapleader = ' '


--
-- plugins
vim.pack.add({
  -- sort by repo name with `:sort /.*\// i`
  { src = "https://github.com/saghen/blink.cmp.git", version = vim.version.range("^1") },
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://codeberg.org/andyg/leap.nvim',
  'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim.git',
  'https://github.com/mason-org/mason.nvim.git',
  'https://github.com/nvim-mini/mini.nvim',
  'https://github.com/neovim/nvim-lspconfig.git',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/folke/snacks.nvim',
})


--
-- leap: fast buffer navigation
vim.keymap.set({'n', 'x', 'o'}, '<leader>s', '<Plug>(leap)',    { desc = 'search with leap.nvim' })


--
-- mini: misc plugins
require('mini.surround').setup()
require('mini.trailspace').setup()

local function toggle_trailing_whitespace()
  vim.g.minitrailspace_disable = not vim.g.minitrailspace_disable
  if vim.g.minitrailspace_disable then
    MiniTrailspace.unhighlight()
  else
    MiniTrailspace.highlight()
  end
end

vim.keymap.set({'n'}, '<leader>tt', toggle_trailing_whitespace, { desc = 'toggle trailing whitespace highlights' })
vim.keymap.set({'n'}, '<leader>ts', MiniTrailspace.trim, { desc = 'trim trailing whitespace' })


--
-- snacks.nvim -- see examples at: https://tduyng.com/blog/vim-pack-and-snacks/
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
      explorer = { layout = { layout = { position = "right", }, }, },
    },
  },
})

vim.keymap.set('n', '<leader>e',        function() Snacks.explorer() end,       { desc = 'file explorer' })
vim.keymap.set('n', '<leader>ff',       function() Snacks.picker.smart() end,   { desc = 'smart picker' })
vim.keymap.set('n', '<leader>fk',       function() Snacks.picker.keymaps() end, { desc = 'keymaps' })
vim.keymap.set('n', '<leader><leader>', function() Snacks.picker() end,         { desc = 'choose picker' })
vim.keymap.set('n', '<leader>gg',       function() Snacks.lazygit() end,        { desc = 'lazygit' })
vim.keymap.set('n', '<leader>gx',       function() Snacks.gitbrowse() end,      { desc = 'open line in browser' })


--
-- LSP
require("mason").setup()

require("mason-tool-installer").setup({
  ensure_installed = {
    -- servers
    "basedpyright",
    "bash-language-server",
    "eslint-lsp",
    "kotlin-language-server",
    "lua-language-server",
    "ruff",
    "typescript-language-server",
    -- formatters
    "ktlint",
    "prettier",
    "shfmt",
    "stylua",
  },
  auto_update = false,
  run_on_start = true,
})

vim.lsp.config("bashls", {
  filetypes = { "sh", "bash", "zsh" },
})

vim.lsp.config("lua_ls", {
  settings = { Lua = { diagnostics = { globals = { "vim" } } } },
})

vim.lsp.config("kotlin_language_server", {
  init_options = {
    storagePath = vim.fn.stdpath("cache") .. "/kotlin_language_server",
  },
})

vim.lsp.enable({
  "basedpyright",
  "bashls",
  "eslint",
  "kotlin_language_server",
  "lua_ls",
  "ruff",
  "ts_ls",
})

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "go to definition" })


--
-- formatting
require("conform").setup({
  formatters_by_ft = {
    kotlin = { "ktlint" },
    lua = { "stylua" },
    python = { "ruff_organize_imports", "ruff_format" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
    ["_"] = { "prettier" },
  },
  formatters = {
    stylua = {
      prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
    },
    shfmt = {
      prepend_args = { "-i", "2", "-ci" },
    },
  },
})

vim.keymap.set({ "n", "x" }, "<leader>fo", function()
  local mode = vim.api.nvim_get_mode().mode
  require("conform").format({ async = mode == "n", lsp_format = "fallback" })
end, { desc = "format buffer or selection" })


--
-- autocompletion
require("blink.cmp").setup({
  keymap = { preset = "super-tab" },
  appearance = { nerd_font_variant = "mono", },
  completion = { documentation = { auto_show = true }, },
  sources = { default = { "lsp", "path", "snippets", "buffer" }, },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})


--
-- colorscheme
vim.cmd.colorscheme("catppuccin")


--
-- local functions

local function toggle_colorcolumn()
  vim.wo.colorcolumn = vim.wo.colorcolumn == '' and '80,120' or ''
end


--
-- autocommands

-- -- auto-detect project root
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(args)
    local root = vim.fs.root(args.buf, { ".git" })
    if root and root ~= vim.fn.getcwd() then
      vim.fn.chdir(root)
    end
  end
})


--
-- keymaps
vim.keymap.set({'n', 'v'},  '<leader>p',  '"+p',                        { desc = 'paste from system clipboard' })
vim.keymap.set({'n', 'v'},  '<leader>P',  '"+P',                        { desc = 'paste before from system clipboard' })
vim.keymap.set({'n', 'v'},  '<leader>y',  '"+y',                        { desc = 'yank to system clipboard' })
vim.keymap.set({'n'},       '<leader>bb', '<C-^>',                      { desc = 'switch to previous buffer' })
vim.keymap.set({'v'},       '>',          '>gv',                        { desc = 'continuous indent' })
vim.keymap.set({'v'},       '<',          '<gv',                        { desc = 'continuous dedent' })
vim.keymap.set({'n'},       '<leader>tc', toggle_colorcolumn,           { desc = 'toggle colorcolumn' })
vim.keymap.set({'n'},       '<leader>tr', ':set relativenumber!<CR>',   { desc = 'toggle relative numbers' })
vim.keymap.set({'n'},       '<leader>tw', ':set wrap!<CR>',             { silent = true, desc = 'toggle line wrap' })
vim.keymap.set({'n'},       '<A-Up>',     ':m .-2<CR>==',               { silent = true, desc = 'move line up' })
vim.keymap.set({'n'},       '<A-Down>',   ':m .+1<CR>==',               { silent = true, desc = 'move line down' })
vim.keymap.set({'v'},       '<A-Up>',     ":m '<-2<CR>gv=gv",           { silent = true, desc = 'move selection up' })
vim.keymap.set({'v'},       '<A-Down>',   ":m '>+1<CR>gv=gv",           { silent = true, desc = 'move selection down' })
vim.keymap.set({'n', 'v'},  'j',          "v:count == 0 ? 'gj' : 'j'",  { expr = true, silent = true, desc = 'move down visual line' })
vim.keymap.set({'n', 'v'},  'k',          "v:count == 0 ? 'gk' : 'k'",  { expr = true, silent = true, desc = 'move up visual line' })


--
-- options
vim.opt.autoindent = true       -- copy indent from current line to next
vim.opt.breakindent = true      -- indent wrapped lines to match line start
vim.opt.cursorline = true       -- highlight current line
vim.opt.expandtab = true        -- use spaces instead of tabs
vim.opt.ignorecase = true       -- ignore case while searching
vim.opt.number = true           -- show line number
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

