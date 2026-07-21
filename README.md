# 🌙 Configuração do LunarVim (O Melhor dos Dois Mundos)

Este repositório contém uma configuração super otimizada do [LunarVim](https://www.lunarvim.org/), pensada para ser uma IDE de terminal rápida, bonita e cheia de recursos visuais e integrações úteis.

Esta configuração integra os padrões mais modernos do ecossistema Neovim (como a instalação automática de servidores via Mason) com plugins visuais potentes.

---

## ✨ Funcionalidades Inclusas

- **Autocompletar e Inteligência (LSP):**
  - **Python:** `pyright` + `black` (formatação) + `flake8` (linting)
  - **PHP:** `intelephense` (com suporte para ler arquivos de projetos grandes)
  - **JS/TS, Node:** `tsserver` + `prettier` (formatação)
  - **Web (HTML, CSS, JSON, Angular):** Autocompletar e formatação configurados com `prettier`.
- **Banco de Dados no Terminal:**
  - `vim-dadbod` e suas interfaces, para rodar queries e acessar dados direto do editor, incluindo auto-complete de SQL. (Atalho `<leader>db`)
- **Minimapa:**
  - Um mapa do código na lateral direita estilo VSCode, usando `mini.map`. (Atalho `<leader>mm`)
- **Visual e Produtividade:**
  - **Sidebar:** Explorador de arquivos e símbolos.
  - **Autotag:** Fechamento automático de tags (HTML, JSX, TSX, XML).
  - **Colorizer:** Destaque de cores hexadecimais (ex: `#FF0000`) pintadas no próprio código.
  - **Lualine:** Mostra o caminho completo da pasta no rodapé.
  - **Fundo Transparente:** Integra-se com a opacidade do seu emulador de terminal.
  - **Laravel Blade:** Suporte a destaque de sintaxe para templates PHP Blade.

---

## 🛠️ Como Instalar e Usar no seu Computador

### ⚡ Jeito rápido (recomendado): script de setup

Instala e configura **tudo** (dependências, cliente MySQL, LunarVim, symlink desta config, formatadores `black`/`prettier`, a **FiraCode Nerd Font** e o esqueleto das conexões do dadbod). Funciona em **Ubuntu/Debian** e **Arch**, é **idempotente** (pode repetir) e faz **backup** de qualquer config antiga do lvim.

```bash
git clone https://github.com/leandro-de-paula/lunarvim_config.git ~/Dev/lunarvim_config
cd ~/Dev/lunarvim_config
./setup.sh
```

Ele pede `sudo` só para os pacotes de sistema. No fim, mostra uma validação. Depois: abra um terminal novo, **aplique a FiraCode Nerd Font** (o script já a instalou) nas preferências do seu terminal, preencha `~/.config/dadbod/connections.env` com suas conexões e rode `lvim`.

> A fonte é **instalada** pelo script, mas **aplicá-la** no emulador de terminal é um passo manual (config gráfica). Pule a instalação da fonte com `SKIP_FONT=1 ./setup.sh`.

### 🔧 Jeito manual (passo a passo)

A ideia é usar link simbólico, assim você edita os arquivos aqui e o LunarVim já absorve as mudanças.

1. **Instale as dependências básicas no sistema:**
   - **Ubuntu/Debian:** `sudo apt install -y neovim git make python3-pip npm nodejs cargo ripgrep curl unzip fontconfig`
   - **Arch Linux:** `sudo pacman -S --needed neovim git make python-pip npm nodejs cargo ripgrep curl unzip fontconfig`
2. **Instale uma Nerd Font** (ex: *FiraCode Nerd Font*) e aplique nas configurações do seu emulador de terminal.
3. **Instale o LunarVim:**
   ```bash
   bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
   ```
4. **Clone este repositório** para a sua pasta de desenvolvimento:
   ```bash
   git clone https://github.com/leandro-de-paula/lunarvim_config.git ~/Dev/lunarvim_config
   ```
5. **Crie o link simbólico (Symlink)** — com backup, sem `rm -rf`:
   ```bash
   [ -e ~/.config/lvim ] && mv ~/.config/lvim ~/.config/lvim.bak.$(date +%Y%m%d%H%M%S)
   ln -s ~/Dev/lunarvim_config ~/.config/lvim
   ```
6. **Instale os formatadores** (não vêm automáticos): dentro do lvim, `:MasonInstall black prettier` — ou pelo sistema: `npm install -g prettier` e `pipx install black`.

Pronto! Agora basta digitar `lvim` no terminal. Na primeira execução, ele baixa os plugins e os LSPs automaticamente.

---

## 🗄️ Guia de Banco de Dados (Para Estagiários/Iniciantes)

A nossa configuração usa o plugin **Dadbod** para gerenciar bancos de dados diretamente do editor. Ele suporta MySQL/MariaDB, PostgreSQL, SQL Server, SQLite, entre outros.

> 📚 **Tutorial completo e detalhado:** `~/Dev/my-kindle/mds/tutorial-lunarvim.md` (instalação, uso e banco de dados passo a passo, para os dois sistemas operacionais).

> ⚠️ **Pré-requisito obrigatório:** o dadbod **não fala com o banco sozinho** — ele chama o cliente de linha de comando (`mysql` para MySQL/MariaDB, `psql` para PostgreSQL, `sqlcmd` para SQL Server). Sem o cliente, nada roda. Para MySQL/MariaDB:
> ```bash
> sudo apt install -y mysql-client-core-8.0     # Ubuntu/Debian
> sudo pacman -S --needed mariadb-clients        # Arch Linux (fornece /usr/bin/mysql)
> ```
> Confirme com `mysql --version`.

### 🔐 Como as conexões são definidas (sem senha no repositório)

As conexões **não** carregam senha no `config.lua`. Elas vêm de **variáveis de ambiente** com o prefixo `DBUI_`, guardadas fora do repositório em `~/.config/dadbod/connections.env` (permissão `600`) e carregadas automaticamente pelo `~/.zshrc`.

Convenção: cada `export DBUI_<Nome>="<url>"` vira uma conexão no lvim; o **rótulo** exibido é `<Nome>` com `_` trocado por espaço. Exemplo do arquivo:

```bash
# ~/.config/dadbod/connections.env   (chmod 600, fora do git)
export DBUI_FRC1607_movida_gtf_Vetor="mysql://usuario:senha@10.87.12.11:3306/movida_gtf"
export DBUI_Hinode_MSSQL="sqlserver://usuario:senha@10.0.1.200/hinode"
```

> Adicionar uma conexão nova = adicionar uma linha `DBUI_...`, dar `source ~/.config/dadbod/connections.env` (ou abrir um terminal novo) e reabrir o lvim. **Não** precisa editar o `config.lua`.
>
> ⚠️ Se a senha tiver caractere especial (`@ : / ? & % < > *`, espaço…), faça **URL-encode** dela na URL (`@` → `%40`, `%` → `%25`, etc.).

Formatos de URL: `mysql://…`, `postgresql://…`, `sqlserver://…`, `sqlite:/caminho/arquivo.db`.

### ▶️ Abrir e rodar um script `.sql` e ver o resultado

1. Abra o `.sql` no lvim (ex.: `lvim caminho/do/script.sql`).
2. **Conecte o buffer a um banco:** `<Espaço> d c` → abre um menu com as conexões (`vim.g.dbs`); escolha uma. Aparece uma notificação "Buffer conectado a: …".
3. **Rode e veja o resultado num split de preview:**
   - **Só um trecho:** entre em modo visual (`V`), selecione as linhas e tecle `<Espaço> r r`.
   - **O arquivo inteiro:** `<Espaço> r a`.
4. O resultado costuma vir **dobrado** (linha `+-- N lines:`). Pule para a janela de baixo com `Ctrl-w j` e tecle `zR` para abrir a dobra. Feche o resultado com `:q`.

**Atalhos de banco desta config:**

| Atalho | Ação |
| :--- | :--- |
| `<leader>db` | Abrir/fechar a árvore do dadbod-ui |
| `<leader>dc` | Escolher a conexão do buffer atual (menu) |
| `<leader>rr` | (visual) Rodar a **seleção** na conexão do buffer |
| `<leader>ra` | Rodar o **arquivo inteiro** na conexão do buffer |

> `<leader>` é a tecla líder (por padrão, `Espaço`). O aviso `Using a password on the command line interface can be insecure` que aparece no resultado **não impede a execução** (o cliente `mysql` recebe a senha por argumento), mas evite expor esse terminal/prints/logs — a senha pode aparecer.

---

## ⚠️ Troubleshooting (Problemas Comuns)

**Erro vermelho do `none-ls` no Neovim 0.10+**
O LunarVim por padrão trava as versões dos plugins (pin). Ao utilizar o Neovim 0.10+, o plugin interno `none-ls` original lançava um erro `attempt to index field '_request_name_to_capability' (a nil value)`.
**A Solução já está inclusa:** o `config.lua` **fixa o `none-ls` num commit específico conhecido como compatível** (bloco `nvimtools/none-ls.nvim` com `pin = true`), evitando que uma versão nova reintroduza o erro.

---

## 📝 Personalização
Se desejar alterar algo, edite diretamente o arquivo `config.lua` neste repositório. As mudanças serão aplicadas ao salvar, e você poderá fazer `git push` para guardar sua configuração na nuvem.
