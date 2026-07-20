-- =========================================
--  Configuração do LunarVim (O Melhor dos 2 Mundos)
-- =========================================

-- 1. Instalar parsers de sintaxe (Tree-sitter)
lvim.builtin.treesitter.ensure_installed = {
  "python", "php", "javascript", "typescript", "html", "css", "json", "tsx"
}
lvim.builtin.treesitter.highlight.enabled = true

-- Desativar indent-blankline v2 nativo do LunarVim (quebra no Neovim 0.12+)
lvim.builtin.indentlines.active = false

-- 2. Instalar os LSPs automaticamente (Inteligência da linguagem)
lvim.lsp.installer.setup.ensure_installed = {
  "pyright",       -- Python
  "intelephense",  -- PHP
  "angularls",     -- Angular
  "tsserver",      -- Node / JavaScript / TypeScript
  "html",
  "cssls",
  "jsonls"
}

-- Configuração específica para o PHP (Intelephense - permitir arquivos grandes)
local lspconfig = require("lspconfig")
lspconfig.intelephense.setup({
  settings = {
    intelephense = {
      files = { maxSize = 7000000 },
    },
  },
})

-- 3. Configurar Formatadores e Linters
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup {
  { command = "black", filetypes = { "python" } },
  {
    command = "prettier",
    filetypes = { "javascript", "typescript", "typescriptreact", "javascriptreact", "css", "html", "json", "angular" },
  },
}

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  -- flake8 foi removido dos builtins do none-ls. O Pyright já lida bem com os diagnósticos.
}

-- 4. Plugins Extras
lvim.plugins = {
  -- Consertar o erro do none-ls no Neovim 0.10+
  {
    "nvimtools/none-ls.nvim",
    commit = "01f8e62ea11603e59ad9ff7afcfa94fd183f76d6",
    pin = true,
  },
  
  -- Consertar o erro do treesitter no Neovim 0.12+
  {
    "nvim-treesitter/nvim-treesitter",
    commit = "cf12346a3414fa1b06af75c79faebe7f76df080a",
    pin = true,
    build = ":TSUpdate",
  },
  
  -- Consertar o erro do nvim-tree no Neovim 0.12+ (vim.diagnostic.is_disabled)
  {
    "nvim-tree/nvim-tree.lua",
    pin = false,
  },
  
  -- Substituir o indent-blankline pelo v3 (compatível com Neovim 0.12+)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
  },
  
  -- Suporte para Blade Templates (Laravel)
  { "jwalton512/vim-blade" },

  -- Renderização de Markdown no próprio terminal (WYSIWYG)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown", "norg", "rmd", "org" },
    config = function()
      require("render-markdown").setup({})
    end,
  },
  
  -- Snippets Extras
  { "rafamadriz/friendly-snippets" },
  
  -- Sidebar (explorador à direita)
  {
    "sidebar-nvim/sidebar.nvim",
    config = function()
      require("sidebar-nvim").setup({
        sections = { "symbols", "files" },
      })
    end,
  },
  
  -- Minimap (mapa do código)
  {
    "echasnovski/mini.map",
    version = false,
    config = function()
      require("mini.map").setup({
        integrations = {
          require("mini.map").gen_integration.builtin_search(),
          require("mini.map").gen_integration.diagnostic(),
        },
        symbols = {
          encode = require("mini.map").gen_encode_symbols.dot("4x2"),
        },
        window = { side = "right", width = 10, winblend = 15 },
      })
    end,
  },
  
  -- Ferramentas para Banco de Dados (Dadbod)
  { "tpope/vim-dadbod" },
  { "kristijanhusak/vim-dadbod-ui" },
  { "kristijanhusak/vim-dadbod-completion" },
  
  -- Fechamento automático de tags HTML/JSX
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup({
        filetypes = { "html", "xml", "javascriptreact", "typescriptreact" },
      })
    end,
  },
  
  -- Colorizer (para cores HEX/RGB)
  { "norcalli/nvim-colorizer.lua" },
}

-- 5. Configurações dos Plugins Visuais



-- Caminho do arquivo na Lualine (rodapé)
lvim.builtin.lualine.sections.lualine_c = {
  {
    "filename",
    path = 1, -- 1 = Caminho relativo
    shorting_target = 40,
  },
}

-- 6. Configurações do Banco de Dados (Dadbod)
-- ATENÇÃO: o vim-dadbod chama o CLIENTE de linha de comando do banco.
--   MySQL/MariaDB -> `mysql`   PostgreSQL -> `psql`   SQL Server -> `sqlcmd`
-- Instale o cliente do MySQL antes de usar:
--   Ubuntu/Debian: sudo apt install -y mysql-client-core-8.0
--   Arch Linux:    sudo pacman -S --needed mariadb-clients   (fornece /usr/bin/mysql)
vim.cmd([[
  autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer { sources = { { name = 'vim-dadbod-completion' } } }
]])
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_show_database_icon = 1
vim.g.db_ui_execute_on_save = 0 -- não roda ao salvar; execução é explícita pelos atalhos
-- Adicionar SQL ao auto-complete do LunarVim
lvim.builtin.cmp.sources = {
    { name = "nvim_lsp" },
    { name = "vim-dadbod-completion" },
    { name = "buffer" },
    { name = "path" },
}

-- 6.1 Conexões de banco (genérico, multi-projeto)
-- As URLs NUNCA ficam no repositório: vêm de variáveis de ambiente com o
-- prefixo DBUI_, carregadas pelo shell (ex.: ~/.config/dadbod/connections.env
-- via ~/.zshrc). Cada variável DBUI_<Nome>=<url> vira uma conexão no lvim;
-- o rótulo exibido é <Nome> com "_" trocado por espaço.
-- Para adicionar uma conexão, basta criar outra variável DBUI_ — sem editar aqui.
local dbs = {}
for name, value in pairs(vim.fn.environ()) do
  local label = name:match("^DBUI_(.+)$")
  if label and value ~= nil and value ~= "" then
    dbs[label:gsub("_", " ")] = value
  end
end
vim.g.dbs = dbs

-- Conectar o buffer SQL atual a uma das conexões (menu de escolha).
-- Depois de conectar: <leader>ra roda o buffer inteiro; em modo visual,
-- selecione linhas e use <leader>rr para rodar só a seleção.
local function db_pick()
  local labels = {}
  for label, _ in pairs(vim.g.dbs or {}) do
    table.insert(labels, label)
  end
  table.sort(labels)
  if #labels == 0 then
    vim.notify("Nenhuma conexão encontrada.\nDefina variáveis DBUI_* (ex.: ~/.config/dadbod/connections.env) e reabra o lvim.", vim.log.levels.WARN)
    return
  end
  vim.ui.select(labels, { prompt = "Conectar buffer ao banco:" }, function(choice)
    if choice then
      vim.b.db = vim.g.dbs[choice]
      vim.notify("Buffer conectado a: " .. choice)
    end
  end)
end
vim.api.nvim_create_user_command("DbPick", db_pick, {})

-- Atalhos
lvim.keys.normal_mode["<leader>db"] = ":DBUIToggle<CR>"  -- abre/fecha a árvore do dadbod-ui
lvim.keys.normal_mode["<leader>dc"] = ":DbPick<CR>"      -- escolher a conexão do buffer atual
lvim.keys.normal_mode["<leader>ra"] = ":%DB<CR>"         -- rodar o BUFFER inteiro na conexão do buffer (b:db)
lvim.keys.visual_mode["<leader>rr"] = ":DB<CR>"          -- rodar a SELEÇÃO (visual) na conexão do buffer
lvim.keys.normal_mode["<leader>mm"] = ":lua MiniMap.toggle()<CR>"
lvim.keys.normal_mode["<leader>mp"] = ":RenderMarkdown toggle<CR>"

-- 7. Interface e Transparência
lvim.builtin.terminal.active = true
lvim.transparent_window = true
vim.opt.termguicolors = true
vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NormalNC guibg=NONE ctermbg=NONE
  highlight NonText guibg=NONE ctermbg=NONE
  highlight LineNr guibg=NONE ctermbg=NONE
  highlight Folded guibg=NONE ctermbg=NONE
]])
