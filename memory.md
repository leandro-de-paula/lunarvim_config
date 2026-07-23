# Memory - LunarVim Config - Handoff de Contexto

> Atualizado em: 2026-07-21 14:34 -03
> Objetivo: permitir retomada do projeto `lunarvim_config` sem perder decisoes, escopo, comandos de manutencao e estado do repositorio.

## Sessao desta atualizacao

> Antigravity (Gemini 3.1 Pro High)

Model:              Gemini 3.1 Pro (High)
Session:            34e14553-3088-45a1-a3a2-d895e22c9a50
Updated at:         2026-07-23 19:42 -03
Atividade:          Resolucao de conflito de atalhos (Which-Key) do Dadbod com o DAP no LunarVim

```text
> Antigravity (Gemini 3.1 Pro High)

Model:              Gemini 3.1 Pro (High)
Session:            52f258c7-79fb-48d1-a2f4-87c9fa4d5989
Updated at:         2026-07-22 23:50 -03
Atividade:          Correção de erro 'unbound variable' no setup.sh no Arch Linux

```text
> Codex (GPT-5.5 / xhigh)

Model:              GPT-5.5 / Codex
Reasoning effort:   xhigh
Directory:          /home/leandro/Dev/lunarvim_config
Permissions:        Full Access
Collaboration mode: Default
Session:            019f810f-ffcc-7db1-85cd-3dfd32d3dc8e
Updated at:         2026-07-21 14:34 -03
Atividade:          Criacao dos handoffs memory.md e resume_ia.md
```

## 0. Status autoritativo mais recente

- Projeto: `lunarvim_config`.
- Pasta: `/home/leandro/Dev/lunarvim_config`.
- Remoto: `https://github.com/leandro-de-paula/lunarvim_config.git`.
- Branch principal: `main`.
- Estado antes destes handoffs: `main` alinhado com `origin/main`.
- Ultimo commit enviado: `087eec4 setup: sincroniza config e documenta manutencao`.
- Arquivos principais do projeto: `setup.sh`, `README.md`, `config.lua`, `lazy-lock.json`, `dadbod_config.vim`.
- Arquivos criados nesta sessao: `memory.md` e `resume_ia.md`.

## 1. Objetivo do projeto

Este repositorio guarda a configuracao pessoal do LunarVim usada como IDE de terminal para desenvolvimento em Python, PHP, JavaScript/TypeScript, Node, web e SQL.

A estrategia e usar um link simbolico:

```text
~/.config/lvim -> ~/Dev/lunarvim_config
```

Assim, o LunarVim carrega diretamente esta config e qualquer ajuste versionado aqui pode ser sincronizado entre maquinas com Git.

## 2. Funcionalidades cobertas pela config

- LSP/Inteligencia:
  - Python: `pyright`.
  - PHP: `intelephense` com suporte a arquivos maiores.
  - Angular: `angularls`.
  - JavaScript/TypeScript/Node: `tsserver`.
  - HTML/CSS/JSON: `html`, `cssls`, `jsonls`.
- Formatacao:
  - Python: `black`.
  - JS/TS/HTML/CSS/JSON/Angular: `prettier`.
- Banco de dados:
  - `vim-dadbod`, `vim-dadbod-ui`, `vim-dadbod-completion`.
  - Conexoes via variaveis de ambiente `DBUI_*`, fora do Git.
  - Arquivo local esperado: `~/.config/dadbod/connections.env`.
- Git/Source Control:
  - Gitsigns nos arquivos.
  - LazyGit como tela completa de Git dentro do LunarVim.
- Visual/produtividade:
  - `sidebar.nvim`.
  - `mini.map`.
  - `render-markdown.nvim`.
  - `nvim-ts-autotag`.
  - `nvim-colorizer.lua`.
  - Suporte a Laravel Blade.
  - Janela transparente.
- Compatibilidade:
  - `none-ls.nvim` fixado em commit conhecido como compativel.
  - `nvim-treesitter` fixado em commit conhecido como compativel.
  - `indent-blankline` nativo desativado e substituido por `indent-blankline.nvim` v3.

## 3. Setup recomendado

Uso normal em Arch ou Ubuntu/Debian:

```bash
cd ~/Dev/lunarvim_config
git pull --ff-only
./setup.sh
```

Esse fluxo deve:

- instalar dependencias de sistema;
- instalar LunarVim se ainda nao existir;
- garantir `~/.local/bin` no `PATH`;
- sincronizar este repositorio com `origin/<branch>` se estiver limpo;
- apontar `~/.config/lvim` para este repositorio;
- instalar `black`, `prettier`, LazyGit e FiraCode Nerd Font;
- sincronizar plugins com `Lazy! sync`;
- criar/preservar `~/.config/dadbod/connections.env`;
- validar comandos principais no fim.

## 4. Manutencao controlada

Para forcar atualizacao/reinstalacao do LazyGit:

```bash
cd ~/Dev/lunarvim_config
git pull --ff-only
UPDATE_LAZYGIT=1 ./setup.sh
```

Variaveis uteis:

```bash
SKIP_FONT=1 ./setup.sh       # pula instalacao da fonte
SKIP_REPO_SYNC=1 ./setup.sh  # nao tenta sincronizar este repositorio
SKIP_LVIM_SYNC=1 ./setup.sh  # nao roda Lazy sync automaticamente
```

Atualizacao do core do LunarVim:

```text
Abrir o editor -> :LvimUpdate -> :qa -> abrir novamente com lvim
```

Decisao tomada: nao atualizar o core do LunarVim automaticamente em todo `setup.sh`, porque isso pode quebrar plugins, atalhos ou comportamento sem aviso. O setup deve ser previsivel; updates maiores devem ser acao consciente.

## 5. Limites de seguranca do setup

O `setup.sh` foi desenhado para ser idempotente e conservador.

Ele nao deve:

- sobrescrever alteracoes locais no repositorio;
- resolver branch divergente automaticamente;
- apagar config antiga de `~/.config/lvim` sem backup;
- preencher senha de banco;
- aplicar a fonte no emulador de terminal;
- atualizar agressivamente o core do LunarVim sozinho.

Se houver alteracoes locais, o sync do repo e pulado com aviso. A pessoa deve revisar com `git status`, `git diff`, commit/stash ou resolver manualmente.

## 6. Source Control dentro do LunarVim

O equivalente mais proximo do Source Control do VSCode e o LazyGit.

Atalho principal:

```text
<Espaco> g g
```

Pre-requisito: binario `lazygit` no `PATH`. O `setup.sh` instala:

- Arch: via `pacman`.
- Ubuntu/Debian: tenta `apt`; se nao houver pacote, baixa release oficial para `~/.local/bin`.

Tambem existem atalhos de Gitsigns/Telescope no menu `<Espaco> g`.

## 7. Banco de dados

As conexoes nao ficam versionadas no repo.

Arquivo local:

```text
~/.config/dadbod/connections.env
```

Formato:

```bash
export DBUI_Nome_Da_Conexao="mysql://usuario:senha@host:porta/banco"
```

Cuidados:

- manter permissao `600`;
- nao commitar senhas;
- URL-encode em senhas com caracteres especiais;
- reiniciar o terminal ou rodar `source ~/.config/dadbod/connections.env` apos alterar.

Atalhos principais:

- `<Espaco> d b`: abre/fecha a arvore do dadbod-ui.
- `<Espaco> d c`: escolhe conexao do buffer atual.
- `<Espaco> r r`: roda selecao visual SQL.
- `<Espaco> r a`: roda o arquivo SQL inteiro.

## 8. Tutorial externo

Existe um tutorial detalhado fora deste repositorio:

```text
/home/leandro/Dev/my-kindle/mds/tutorial-lunarvim.md
```

Esse tutorial foi expandido para estagiario/iniciante, incluindo:

- historia resumida e motivo de usar LunarVim;
- instalacao Ubuntu/Arch;
- sobrevivencia completa no Neovim;
- buffers/guias e leader;
- Source Control/Git;
- exemplos praticos com SQL, PHP, Python, Node, JS, jQuery e Ajax;
- orientacao sobre debug real com breakpoints;
- uso de Dadbod para banco.

Observacao: esse arquivo pertence a outro projeto/pasta e nao foi incluido no commit do `lunarvim_config`.

## 9. Historico recente

- **Ajustes retroativos de compatibilidade (Jul/2026):**
  - Downgrade do Neovim de `0.12` (nightly) para `0.10.0` (stable) efetuado para contornar remocao do metodo `node:range()` no Treesitter.
  - Implementado o plugin `render-markdown.nvim` no `config.lua` para garantir visualizacao de markdown WYSIWYG dentro do terminal (em vez de navegadores).
  - Configurado explicitamente o caminho da "FiraCode Nerd Font" nos settings do terminal Warp para consertar icones quadrados ausentes no LunarVim.
  - Plugin `none-ls.nvim` fixado em um commit compativel apos remocao de dependencias legadas no Neovim 0.12.
  - Plugin nativo do `indent-blankline` substituido pela versao 3 e `nvim-treesitter` teve o pin de commit ajustado temporariamente para analises.
- `087eec4 setup: sincroniza config e documenta manutencao` (Codex - 21/07/2026)
  - Commitado e enviado para `origin/main`.
  - Alterou `README.md` e `setup.sh`.
  - Validacoes antes do commit: `bash -n setup.sh` OK e `git diff --check` OK.
- Ajustes principais desse commit:
  - `setup.sh` agora sincroniza o repo de forma segura via fast-forward.
  - `setup.sh` instala LazyGit.
  - `setup.sh` sincroniza plugins com `Lazy! sync`.
  - `setup.sh` valida `lazygit` no fim.
  - `README.md` documenta uso normal, manutencao e limites.
- `xxxxxxxx` fix: corrige unbound variable no setup.sh (Antigravity - 22/07/2026)
  - Separou a declaração das variáveis `dir` e `file` para evitar erro de `unbound variable` no bash com `set -u` (especialmente visível no Arch Linux).
- `42c4b6b` fix: override default debug mappings for dadbod shortcuts (Antigravity - 23/07/2026)
  - Foi identificado que o atalho `<Espaço> d c` acionava o debugger nativo do LunarVim (DAP) causando um erro no carregamento de arquivos `.sql`.
  - Os atalhos padrão do Dadbod (e.g. `<leader>dc` e `<leader>db`) foram reconfigurados no `which-key` para sobrescrever o menu de debug.
  - A operação "Run All" (`<leader>ra`) foi corrigida para integrar adequadamente ao `%DB`.

## 10. Proximos cuidados

- Commitar estes handoffs se eles devem fazer parte oficial do repositorio.
- Evitar colocar credenciais ou conexoes reais em qualquer arquivo versionado.
- Ao mudar atalhos ou plugins, atualizar `README.md`, `memory.md` e, se aplicavel, o tutorial externo.
- Depois de alterar `config.lua`, abrir `lvim` e validar `:Lazy`, `:Mason`, formatacao e atalhos principais.
