-- Configuração do LunarVim

-- Verifica se o Packer está carregado e instala automaticamente se necessário
local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
  print("Installing Packer...") -- Aviso que o Packer está sendo instalado
  vim.cmd("packadd packer.nvim")
end

-- Configuração do LSP para PHP (Intelephense)
lvim.lsp.automatic_configuration.skipped_servers = { "intelephense" }
local lspconfig = require("lspconfig")
lspconfig.intelephense.setup({
  settings = {
    intelephense = {
      files = {
        maxSize = 7000000, -- Permitir arquivos grandes
      },
    },
  },
})

-- Configuração dos LSPs de HTML, CSS e JS
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
  { name = "prettier" }, -- Formatação para HTML, CSS, JS e TS
})

local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
  { name = "eslint_d" }, -- Linter para JavaScript e TypeScript
})

lvim.lsp.automatic_configuration.skipped_servers = {}

-- Configuração para Treesitter
lvim.builtin.treesitter.ensure_installed = {
  "html",
  "css",
  "javascript",
  "typescript",
}
lvim.builtin.treesitter.highlight.enabled = true

-- Configuração do autotag para HTML e JSX
require("nvim-ts-autotag").setup({
  filetypes = { "html", "xml", "javascriptreact", "typescriptreact" },
})

-- Adicionando plugins
lvim.plugins = {
  -- Suporte para Blade Templates
  { "jwalton512/vim-blade" },

  -- Snippets para PHP e Laravel
  { "rafamadriz/friendly-snippets" },
  { "L3MON4D3/LuaSnip" },

  -- Ícones para arquivos
  { "kyazdani42/nvim-web-devicons" },

  -- Sidebar com símbolos e arquivos
  { "sidebar-nvim/sidebar.nvim" },

  -- Plugin para minimap
  {
    "echasnovski/mini.map",
    version = false, -- Usar a versão mais recente
    config = function()
      require("mini.map").setup({
        integrations = {
          require("mini.map").gen_integration.builtin_search(),
          require("mini.map").gen_integration.diagnostic(),
        },
        symbols = {
          encode = require("mini.map").gen_encode_symbols.dot("4x2"),
        },
        window = {
          side = "right", -- Minimapa à direita
          width = 10, -- Largura do minimapa
          winblend = 15, -- Transparência
        },
      })
    end,
  },

  -- Ferramentas para banco de dados
  { "tpope/vim-dadbod" },
  { "kristijanhusak/vim-dadbod-ui" },
  { "kristijanhusak/vim-dadbod-completion" },

  -- Plugin para sintaxe HTML
  { "windwp/nvim-ts-autotag" },

  -- Plugin para CSS e SCSS
  { "norcalli/nvim-colorizer.lua" },

  -- Plugins para JavaScript/TypeScript
  { "pangloss/vim-javascript" },
  { "maxmellon/vim-jsx-pretty" },
}

-- Configuração para integração com SQL
vim.cmd([[
  autocmd FileType sql lua require('cmp').setup.buffer { sources = { { name = 'vim-dadbod-completion' } } }
]])

-- Ativar fontes Nerd para a interface do banco
vim.g.db_ui_use_nerd_fonts = 1

-- Configuração do sidebar
require("sidebar-nvim").setup({
  sections = { "symbols", "files" },
})

-- Configuração do terminal integrado
lvim.builtin.terminal.active = true

-- Atalho para alternar o minimap
lvim.keys.normal_mode["<leader>mm"] = ":lua MiniMap.toggle()<CR>"

-- Add Path
lvim.builtin.lualine.sections.lualine_c = {
  {
    "filename",
    path = 1, -- Exibe o caminho relativo ao projeto
    shorting_target = 40, -- Trunca o path se for muito longo
  },
}

-- Configuração de formatador e linter para Python
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
  { command = "black", filetypes = { "python" } },
})

local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
  { command = "flake8", filetypes = { "python" } },
})

-- Configuração do LSP para Python
lvim.lsp.automatic_configuration.skipped_servers = { "pyright" }
local lspconfig = require("lspconfig")
lspconfig.pyright.setup({})

