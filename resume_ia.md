# Resume IA - LunarVim Config

```text
> Antigravity

Model:              Gemini 3.1 Pro (High)
Directory:          /home/leandro/Dev/lunarvim_config
Permissions:        Full Access
Collaboration mode: Default
Session:            52f258c7-79fb-48d1-a2f4-87c9fa4d5989
Updated at:         2026-07-22 23:50 -03
```

```text
> Codex (GPT-5.5 / xhigh)

Model:              GPT-5.5 / Codex
Reasoning effort:   xhigh
Directory:          /home/leandro/Dev/lunarvim_config
Permissions:        Full Access
Collaboration mode: Default
Session:            019f810f-ffcc-7db1-85cd-3dfd32d3dc8e
Updated at:         2026-07-21 14:34 -03
```

## Status atual

- Projeto: `lunarvim_config`.
- Pasta: `/home/leandro/Dev/lunarvim_config`.
- Remoto: `https://github.com/leandro-de-paula/lunarvim_config.git`.
- Branch: `main`.
- Ultimo commit enviado: `d9e54be` (downgrade do neovim e render-markdown) seguido pelos commits do Codex (`087eec4`).
- Estado antes destes handoffs: `main` alinhado com `origin/main`.
- Arquivos de handoff atualizados retroativamente.

## Resumo do projeto

- Configuracao pessoal do LunarVim para usar como IDE de terminal.
- Ativacao por symlink: `~/.config/lvim -> ~/Dev/lunarvim_config`.
- Suporte principal: Python, PHP, JavaScript/TypeScript, Node, Angular, HTML, CSS, JSON, SQL e Blade.
- Formatadores esperados: `black` e `prettier`.
- Banco de dados via Dadbod, com conexoes locais `DBUI_*` em `~/.config/dadbod/connections.env`.
- Source Control dentro do LunarVim via Gitsigns e LazyGit.

## Setup recomendado

```bash
cd ~/Dev/lunarvim_config
git pull --ff-only
./setup.sh
```

O `setup.sh` instala dependencias, LunarVim quando necessario, formatadores, LazyGit, FiraCode Nerd Font, symlink da config, conexoes Dadbod e sincronizacao de plugins.

## Manutencao

```bash
UPDATE_LAZYGIT=1 ./setup.sh  # forca atualizar/reinstalar LazyGit
SKIP_FONT=1 ./setup.sh       # pula fonte
SKIP_REPO_SYNC=1 ./setup.sh  # pula sync do repo
SKIP_LVIM_SYNC=1 ./setup.sh  # pula Lazy sync
```

O core do LunarVim nao e atualizado automaticamente. Para isso, abrir o editor e rodar `:LvimUpdate` conscientemente.

## Guardrails

- Nao versionar senhas nem URLs reais de banco.
- Nao colocar credenciais no `config.lua`.
- Nao forcar pull quando houver alteracoes locais.
- Nao resolver branch divergente automaticamente no script.
- Nao remover config antiga sem backup.
- Aplicar a FiraCode Nerd Font no terminal e passo manual.

## Contribuicoes por agente

- **Antigravity (Gemini 3.1 Pro High) - 2026-07-17:** Configurou e corrigiu o renderizador de Markdown no terminal (`render-markdown.nvim`). Para isso, realizou downgrade do Neovim de `0.12` (nightly) para `0.10.0` (stable) para contornar um crash na API do Treesitter (`node:range()`). Anteriormente, configurou a fonte do Warp Terminal para "FiraCode Nerd Font", consertou o plugin `indent-blankline` e fixou commits seguros para `none-ls.nvim` e `nvim-treesitter`.
- **Antigravity (Gemini 3.1 Pro High) - 2026-07-22:** Corrigiu erro de `unbound variable` ('dir') no arquivo `setup.sh` executado no Arch Linux com `set -uo pipefail`, separando a declaração de múltiplas variáveis na mesma linha `local`.
- **Codex (GPT-5.5 / xhigh) - 2026-07-21:** Revisou e evoluiu `setup.sh` para sincronizacao segura do repo, instalacao do LazyGit, sync de plugins, validacao final e documentacao de manutencao. Commitou e enviou `087eec4` para `origin/main`. Criou estes handoffs (`memory.md` e `resume_ia.md`) seguindo o modelo indicado.
- **Codex (GPT-5.5 / xhigh) - 2026-07-21:** Atualizou o tutorial externo `/home/leandro/Dev/my-kindle/mds/tutorial-lunarvim.md` com introducao historica, guia de sobrevivencia no Neovim, leader, buffers/guias, Source Control, exemplos praticos e orientacoes de debug. Esse arquivo fica fora deste repositorio.
