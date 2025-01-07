
# Configuração do LunarVim

Este repositório documenta uma configuração personalizada do LunarVim, incluindo suporte para PHP, HTML, CSS, JavaScript, TypeScript, Python e integração com bancos de dados. Abaixo, você encontra uma descrição detalhada das configurações e plugins utilizados.

## Requisitos

- [LunarVim](https://www.lunarvim.org/)
- [Packer](https://github.com/wbthomason/packer.nvim)
- Nerd Fonts para suporte à interface de banco de dados

## Configurações Principais

### Gerenciador de Plugins (Packer)
O Packer é instalado automaticamente se não estiver presente:
```lua
local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
  print("Installing Packer...")
  vim.cmd("packadd packer.nvim")
end
```

### Configuração de LSPs
#### PHP (Intelephense)
Configuração para lidar com arquivos grandes:
```lua
lvim.lsp.automatic_configuration.skipped_servers = { "intelephense" }
local lspconfig = require("lspconfig")
lspconfig.intelephense.setup({
  settings = {
    intelephense = {
      files = { maxSize = 7000000 },
    },
  },
})
```

#### HTML, CSS e JavaScript
- **Formatadores:** Prettier
- **Linters:** ESLint
```lua
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
  { name = "prettier" },
})

local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
  { name = "eslint_d" },
})
```

#### Python
- **Formatador:** Black
- **Linter:** Flake8
- LSP configurado com Pyright
```lua
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
  { command = "black", filetypes = { "python" } },
})

local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
  { command = "flake8", filetypes = { "python" } },
})

lvim.lsp.automatic_configuration.skipped_servers = { "pyright" }
lspconfig.pyright.setup({})
```

### Treesitter
Ativa o destaque de sintaxe e instala suportes necessários:
```lua
lvim.builtin.treesitter.ensure_installed = { "html", "css", "javascript", "typescript" }
lvim.builtin.treesitter.highlight.enabled = true
```

### Integração com SQL
Adiciona suporte a bancos de dados:
```lua
vim.cmd([[ autocmd FileType sql lua require('cmp').setup.buffer { sources = { { name = 'vim-dadbod-completion' } } }]])
vim.g.db_ui_use_nerd_fonts = 1
```

### Sidebar
Adiciona um painel lateral com símbolos e arquivos:
```lua
require("sidebar-nvim").setup({
  sections = { "symbols", "files" },
})
```

### Terminal Integrado
Ativa o terminal integrado no LunarVim:
```lua
lvim.builtin.terminal.active = true
```

### Minimapa
Adiciona um minimapa à interface:
```lua
lvim.plugins = {
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
        window = {
          side = "right",
          width = 10,
          winblend = 15,
        },
      })
    end,
  },
}

lvim.keys.normal_mode["<leader>mm"] = ":lua MiniMap.toggle()<CR>"
```

### Outros Plugins
- **Blade Templates:** `jwalton512/vim-blade`
- **Snippets:** `rafamadriz/friendly-snippets`, `L3MON4D3/LuaSnip`
- **Colorizer para CSS:** `norcalli/nvim-colorizer.lua`
- **JavaScript/TypeScript:** `pangloss/vim-javascript`, `maxmellon/vim-jsx-pretty`

## Como Utilizar
1. Instale o LunarVim seguindo as [instruções oficiais](https://www.lunarvim.org/docs/installation).
2. Adicione a configuração acima ao arquivo `~/.config/lvim/config.lua`.
3. Reinicie o LunarVim para aplicar as alterações.

## Licença
Este projeto está licenciado sob a [MIT License](LICENSE).
