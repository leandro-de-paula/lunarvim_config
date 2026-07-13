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

A melhor forma de aplicar essa configuração (o "jeito hacker") é usar links simbólicos, assim você pode editar os arquivos aqui e o LunarVim já absorve as mudanças instantaneamente.

1. **Instale as dependências básicas no sistema:**
   (Git, Node, npm, Python, Cargo, Ripgrep, Neovim).
2. **Instale uma Nerd Font** (ex: *FiraCode Nerd Font*) e aplique nas configurações do seu emulador de terminal.
3. **Instale o LunarVim:**
   ```bash
   bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
   ```
4. **Clone este repositório** para a sua pasta de desenvolvimento:
   ```bash
   gh repo clone leandro-de-paula/lunarvim_config ~/Dev/lunarvim_config
   ```
5. **Crie o link simbólico (Symlink):**
   ```bash
   rm -rf ~/.config/lvim
   ln -s ~/Dev/lunarvim_config ~/.config/lvim
   ```

Pronto! Agora basta digitar `lvim` no terminal. Na primeira execução, ele baixará todos os plugins, LSPs e formatadores automaticamente.

---

## 🗄️ Guia de Banco de Dados (Para Estagiários/Iniciantes)

A nossa configuração usa o plugin **Dadbod** para gerenciar bancos de dados diretamente do editor. Ele suporta MySQL, PostgreSQL, SQLite, entre outros.

**Como conectar a um banco (Passo a passo):**
1. No modo normal do LunarVim, pressione `<Espaço> + db` para abrir a interface.
2. Navegue até a opção `Add Connection` e aperte `Enter`.
3. Insira a string de conexão (URL) do seu banco:
   - **PostgreSQL:** `postgresql://usuario:senha@localhost:5432/nome_do_banco`
   - **MySQL:** `mysql://usuario:senha@localhost:3306/nome_do_banco`
4. Digite um nome para a conexão (ex: `MeuDBLocal`).
5. A partir de agora, você pode explorar as tabelas e, ao criar arquivos `.sql`, terá **autocompletar inteligente** que lê as tabelas e colunas direto do banco!

---

## ⚠️ Troubleshooting (Problemas Comuns)

**Erro vermelho do `none-ls` no Neovim 0.10+**
O LunarVim por padrão trava as versões dos plugins (pin). Ao utilizar o Neovim 0.10+, o plugin interno `none-ls` original lançava um erro `attempt to index field '_request_name_to_capability' (a nil value)`.
**A Solução já está inclusa:** Nossa configuração resolve isso automaticamente destravando o `none-ls` no `config.lua` (`pin = false`), forçando o gerenciador de pacotes a usar a versão compatível mais recente.

---

## 📝 Personalização
Se desejar alterar algo, edite diretamente o arquivo `config.lua` neste repositório. As mudanças serão aplicadas ao salvar, e você poderá fazer `git push` para guardar sua configuração na nuvem.
