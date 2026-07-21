#!/usr/bin/env bash
# =====================================================================
# setup.sh — instala e configura o ambiente do LunarVim desta config.
#
# O que faz (idempotente — pode rodar quantas vezes quiser):
#   1. detecta o sistema (Ubuntu/Debian ou Arch) e o shell (bash/zsh)
#   2. instala as dependências de base
#   3. sincroniza este repositório com origin/<branch> se não houver mudanças locais
#   4. instala o cliente de banco MySQL/MariaDB (para o dadbod)
#   5. garante ~/.local/bin no PATH
#   6. instala o LunarVim (se ainda não existir)
#   7. aponta ~/.config/lvim para este repositório (com backup)
#   8. instala os formatadores black (Python) e prettier (JS/web)
#   9. instala o LazyGit (Source Control completo dentro do lvim)
#  10. instala a FiraCode Nerd Font (pule com SKIP_FONT=1)
#  11. sincroniza plugins do LunarVim com o lazy-lock.json
#  12. cria o esqueleto de ~/.config/dadbod/connections.env + auto-load
#  13. valida no final
#
# Uso:
#   mkdir -p ~/Dev
#   git clone https://github.com/leandro-de-paula/lunarvim_config.git ~/Dev/lunarvim_config
#   cd ~/Dev/lunarvim_config
#   ./setup.sh
#
# Uso normal em uma maquina ja clonada:
#   cd ~/Dev/lunarvim_config
#   git pull --ff-only
#   ./setup.sh
#
# Manutencao controlada:
#   UPDATE_LAZYGIT=1 ./setup.sh  # forca atualizar/reinstalar LazyGit
#   SKIP_FONT=1 ./setup.sh       # pula instalacao da fonte
#   SKIP_REPO_SYNC=1 ./setup.sh  # nao tenta sincronizar este repo
#   SKIP_LVIM_SYNC=1 ./setup.sh  # nao roda :Lazy sync automaticamente
#
# Atualizacao do core do LunarVim:
#   Faca manualmente dentro do editor com :LvimUpdate, depois reinicie o lvim.
#
# Requer sudo apenas para os pacotes de sistema (o script pede a senha).
# =====================================================================
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- helpers de log -------------------------------------------------
c_blue=$'\033[1;34m'; c_green=$'\033[1;32m'; c_yellow=$'\033[1;33m'; c_red=$'\033[1;31m'; c_reset=$'\033[0m'
step() { printf '\n%s==> %s%s\n' "$c_blue" "$*" "$c_reset"; }
ok()   { printf '%s[ok]%s %s\n'   "$c_green"  "$c_reset" "$*"; }
warn() { printf '%s[aviso]%s %s\n' "$c_yellow" "$c_reset" "$*"; }
err()  { printf '%s[erro]%s %s\n' "$c_red"   "$c_reset" "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

# ---- 1. detectar SO / gerenciador de pacotes ------------------------
PM=""
detect_os() {
  step "Detectando sistema"
  local id="" like=""
  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    id="${ID:-}"; like="${ID_LIKE:-}"
  fi
  case "$id $like" in
    *arch*|*manjaro*|*endeavouros*) PM="pacman" ;;
    *debian*|*ubuntu*)              PM="apt" ;;
    *) if   have apt;    then PM="apt"
       elif have pacman; then PM="pacman"
       fi ;;
  esac
  if [ -z "$PM" ]; then
    err "Não reconheci o gerenciador de pacotes (esperado apt ou pacman)."
    err "Instale manualmente as dependências da seção 2 do tutorial e rode de novo."
    exit 1
  fi
  ok "Sistema: ${id:-desconhecido} | gerenciador: $PM"
}

# ---- 2. detectar o arquivo de inicialização do shell ----------------
RC=""
detect_rc() {
  case "${SHELL:-}" in
    */zsh)  RC="$HOME/.zshrc" ;;
    */bash) RC="$HOME/.bashrc" ;;
    *)      RC="$HOME/.profile" ;;
  esac
  touch "$RC"
  ok "Arquivo de shell: $RC"
}

# adiciona uma linha ao RC apenas se ainda não existir
rc_add() {
  local marker="$1" line="$2"
  grep -qF "$marker" "$RC" 2>/dev/null || printf '%s\n' "$line" >> "$RC"
}

# ---- 3. dependências de base ----------------------------------------
install_base() {
  step "Instalando dependências de base (pede sudo)"
  if [ "$PM" = "apt" ]; then
    sudo apt-get update -y \
      && sudo apt-get install -y neovim git make python3-pip \
        nodejs npm cargo ripgrep curl unzip tar fontconfig \
      || { err "falha ao instalar dependências de base"; exit 1; }
  else
    sudo pacman -Syu --needed --noconfirm neovim git make python-pip \
      nodejs npm cargo ripgrep curl unzip tar fontconfig \
      || { err "falha ao instalar dependências de base"; exit 1; }
  fi
  ok "Dependências de base instaladas"
}

# instala o primeiro pacote apt que existir na lista
apt_install_first() {
  local p
  for p in "$@"; do
    if apt-cache show "$p" >/dev/null 2>&1; then
      sudo apt-get install -y "$p" && { echo "$p"; return 0; }
    fi
  done
  return 1
}

# ---- 4. sincronizar este repositório ---------------------------------
# Atualiza a config local sem sobrescrever trabalho local. Se o próprio
# setup.sh mudar durante o fast-forward, reexecuta uma vez para continuar com
# a versão nova do script.
sync_config_repo() {
  step "Sincronizando repositório da config"

  if [ "${SKIP_REPO_SYNC:-0}" = "1" ]; then
    warn "SKIP_REPO_SYNC=1 — pulando sincronização do repositório"
    return
  fi

  if ! git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    warn "$REPO_DIR não parece ser um repositório git — pulando pull"
    return
  fi

  if ! git -C "$REPO_DIR" rev-parse --verify HEAD >/dev/null 2>&1; then
    warn "repositório local ainda não tem commit; não vou fazer pull automático para evitar sobrescrever arquivos"
    return
  fi

  if ! git -C "$REPO_DIR" remote get-url origin >/dev/null 2>&1; then
    warn "remote 'origin' não configurado — pulando pull"
    return
  fi

  local branch
  branch="$(git -C "$REPO_DIR" branch --show-current)"
  if [ -z "$branch" ]; then
    warn "repositório está em detached HEAD — pulando pull automático"
    return
  fi

  if ! git -C "$REPO_DIR" diff --quiet || ! git -C "$REPO_DIR" diff --cached --quiet; then
    warn "há alterações locais no repositório; não vou fazer pull automático"
    warn "faça commit/stash ou rode manualmente: git -C \"$REPO_DIR\" pull --ff-only"
    return
  fi

  local old_setup new_setup local_rev remote_rev
  old_setup="$(sha256sum "$REPO_DIR/setup.sh" 2>/dev/null | awk '{print $1}')"

  if ! git -C "$REPO_DIR" fetch origin "$branch:refs/remotes/origin/$branch"; then
    warn "falha ao buscar origin/$branch — mantendo versão local"
    return
  fi

  local_rev="$(git -C "$REPO_DIR" rev-parse HEAD)"
  remote_rev="$(git -C "$REPO_DIR" rev-parse "origin/$branch")"

  if [ "$local_rev" = "$remote_rev" ]; then
    ok "repositório já está atualizado em origin/$branch"
    return
  fi

  if ! git -C "$REPO_DIR" merge-base --is-ancestor "$local_rev" "$remote_rev"; then
    warn "branch local divergiu de origin/$branch; não vou resolver automaticamente"
    return
  fi

  if ! git -C "$REPO_DIR" merge --ff-only "origin/$branch"; then
    warn "fast-forward falhou — rode git pull --ff-only manualmente"
    return
  fi

  ok "repositório atualizado para origin/$branch"

  new_setup="$(sha256sum "$REPO_DIR/setup.sh" 2>/dev/null | awk '{print $1}')"
  if [ -n "${old_setup:-}" ] && [ -n "${new_setup:-}" ] && [ "$old_setup" != "$new_setup" ]; then
    if [ "${SETUP_REEXECED:-0}" = "1" ]; then
      warn "setup.sh mudou, mas o script já foi reexecutado uma vez; continue manualmente se necessário"
      return
    fi
    warn "setup.sh foi atualizado; reexecutando a versão nova"
    SETUP_REEXECED=1 exec "$0" "$@"
  fi
}

# ---- 5. cliente MySQL/MariaDB (necessário para o dadbod) ------------
install_db_client() {
  step "Instalando cliente MySQL/MariaDB (para o dadbod)"
  if have mysql; then ok "cliente 'mysql' já presente: $(command -v mysql)"; return; fi
  if [ "$PM" = "apt" ]; then
    apt_install_first default-mysql-client mariadb-client mysql-client-core-8.0 >/dev/null \
      || warn "não consegui instalar o cliente MySQL automaticamente — instale manualmente"
  else
    sudo pacman -S --needed --noconfirm mariadb-clients \
      || warn "não consegui instalar mariadb-clients — instale manualmente"
  fi
  if have mysql; then ok "cliente 'mysql' ok: $(mysql --version)"; else warn "cliente 'mysql' ainda ausente"; fi
}

# ---- 6. garantir ~/.local/bin no PATH -------------------------------
ensure_local_bin() {
  step "Garantindo ~/.local/bin no PATH"
  mkdir -p "$HOME/.local/bin"
  rc_add '.local/bin' '[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"  # setup.sh'
  export PATH="$HOME/.local/bin:$PATH"
  ok "~/.local/bin garantido"
}

# ---- 7. LunarVim ----------------------------------------------------
install_lunarvim() {
  step "Instalando LunarVim (se necessário)"
  if have lvim; then ok "LunarVim já instalado: $(command -v lvim)"; return; fi
  warn "O instalador oficial do LunarVim pode fazer algumas perguntas — responda 'y'."
  # usa o mesmo instalador validado (branch padrão do LunarVim). Para forçar
  # uma branch específica, exporte LV_BRANCH antes de rodar o setup.sh.
  bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) \
    || warn "instalador do LunarVim retornou erro — verifique manualmente"
  have lvim && ok "LunarVim instalado" || warn "lvim não encontrado no PATH após instalar (abra um terminal novo)"
}

# ---- 8. apontar a config para este repositório ----------------------
link_config() {
  step "Apontando ~/.config/lvim para este repositório"
  mkdir -p "$HOME/.config"
  local target="$HOME/.config/lvim"
  if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$REPO_DIR" ]; then
    ok "symlink já aponta para $REPO_DIR"; return
  fi
  if [ -e "$target" ] || [ -L "$target" ]; then
    local bak="$target.bak.$(date +%Y%m%d%H%M%S)"
    mv "$target" "$bak"
    warn "config anterior movida para $bak"
  fi
  ln -s "$REPO_DIR" "$target"
  ok "symlink criado: $target -> $REPO_DIR"
}

# ---- 9. formatadores: black (Python) e prettier (JS/web) ------------
install_formatters() {
  step "Instalando formatadores (black, prettier)"

  # prettier via npm, dentro de ~/.local (sem sudo, sempre no PATH)
  if have prettier; then
    ok "prettier já presente: $(prettier --version 2>/dev/null)"
  else
    npm install -g --prefix "$HOME/.local" prettier >/dev/null 2>&1 \
      && ok "prettier instalado ($(prettier --version 2>/dev/null))" \
      || warn "falha ao instalar prettier via npm"
  fi

  # black via pip --user (com fallback para --break-system-packages)
  if have black; then
    ok "black já presente: $(black --version 2>/dev/null | head -1)"
  else
    if python3 -m pip install --user black >/dev/null 2>&1 \
       || python3 -m pip install --user --break-system-packages black >/dev/null 2>&1; then
      ok "black instalado ($(black --version 2>/dev/null | head -1))"
    else
      warn "falha ao instalar black via pip (tente: pipx install black)"
    fi
  fi
}

# ---- 10. LazyGit (Source Control completo dentro do LunarVim) --------
# O LunarVim já tem atalho <leader>gg para LazyGit, mas precisa do binário
# `lazygit` no PATH. Em Arch instalamos pelo pacman; em Debian/Ubuntu tentamos
# apt e caímos para o release oficial do GitHub quando o pacote não existe.
lazygit_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo "x86_64" ;;
    aarch64|arm64) echo "arm64" ;;
    armv6l|armv7l) echo "armv6" ;;
    i386|i686) echo "32-bit" ;;
    *) return 1 ;;
  esac
}

install_lazygit_from_github() {
  local arch tag version asset url checksums tmp
  arch="$(lazygit_arch)" || { warn "arquitetura não suportada para LazyGit: $(uname -m)"; return 1; }

  if [ "${LAZYGIT_VERSION:-latest}" = "latest" ]; then
    tag="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
      | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' | head -1)"
  else
    tag="v${LAZYGIT_VERSION#v}"
  fi

  if [ -z "${tag:-}" ]; then
    warn "não consegui descobrir a versão mais recente do LazyGit"
    return 1
  fi

  version="${tag#v}"
  asset="lazygit_${version}_linux_${arch}.tar.gz"
  url="https://github.com/jesseduffield/lazygit/releases/download/${tag}/${asset}"
  checksums="https://github.com/jesseduffield/lazygit/releases/download/${tag}/checksums.txt"
  tmp="$(mktemp -d)"

  if ! curl -fsSL "$url" -o "$tmp/$asset"; then
    warn "falha ao baixar LazyGit: $url"
    return 1
  fi

  if ! curl -fsSL "$checksums" -o "$tmp/checksums.txt"; then
    warn "falha ao baixar checksums do LazyGit"
    return 1
  fi

  if ! (cd "$tmp" && grep "$asset" checksums.txt | sha256sum -c - >/dev/null 2>&1); then
    warn "checksum do LazyGit não confere"
    return 1
  fi

  if ! tar -xzf "$tmp/$asset" -C "$tmp" lazygit >/dev/null 2>&1; then
    warn "falha ao descompactar LazyGit"
    return 1
  fi

  mkdir -p "$HOME/.local/bin"
  install -m 0755 "$tmp/lazygit" "$HOME/.local/bin/lazygit" \
    || { warn "falha ao instalar LazyGit em ~/.local/bin"; return 1; }

  ok "LazyGit instalado via GitHub ($(lazygit --version 2>/dev/null | head -1))"
}

install_lazygit() {
  step "Instalando LazyGit (Source Control)"
  if have lazygit && [ "${UPDATE_LAZYGIT:-0}" != "1" ]; then
    ok "LazyGit já presente: $(lazygit --version 2>/dev/null | head -1)"
    return
  fi

  if [ "$PM" = "pacman" ]; then
    sudo pacman -S --needed --noconfirm lazygit \
      && { ok "LazyGit instalado pelo pacman"; return; }
    warn "pacman não instalou LazyGit — tentando release oficial do GitHub"
  elif [ "$PM" = "apt" ]; then
    apt_install_first lazygit >/dev/null \
      && { ok "LazyGit instalado pelo apt"; return; }
    warn "pacote lazygit não encontrado no apt — tentando release oficial do GitHub"
  fi

  install_lazygit_from_github \
    || warn "não consegui instalar LazyGit automaticamente — o atalho <leader>gg não funcionará até instalar manualmente"
}

# ---- 11. Nerd Font (FiraCode) — instala os arquivos da fonte --------
# Aplicar a fonte no terminal continua sendo manual (config do emulador).
# Pule com: SKIP_FONT=1 ./setup.sh
install_nerd_font() {
  step "Instalando a FiraCode Nerd Font"
  if [ "${SKIP_FONT:-0}" = "1" ]; then warn "SKIP_FONT=1 — pulando a fonte"; return; fi
  local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
  local dest="$HOME/.local/share/fonts/FiraCodeNerdFont"
  # já instalada? checa o disco (robusto) e o cache do fontconfig
  if ls "$dest"/*.ttf >/dev/null 2>&1 \
     || { have fc-list && fc-list 2>/dev/null | grep -qi "FiraCode Nerd Font"; }; then
    ok "FiraCode Nerd Font já instalada"; return
  fi
  local tmp; tmp="$(mktemp -d)"
  mkdir -p "$dest"
  if curl -fsSL "$url" -o "$tmp/FiraCode.zip"; then
    if unzip -o -q "$tmp/FiraCode.zip" -d "$dest" >/dev/null 2>&1; then
      # mantém só os arquivos de fonte na pasta (remove READMEs/licenças)
      find "$dest" -maxdepth 1 -type f ! -iname '*.ttf' ! -iname '*.otf' -delete 2>/dev/null || true
      have fc-cache && fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1
      ok "FiraCode Nerd Font instalada em $dest"
      warn "Falta APLICAR a fonte 'FiraCode Nerd Font' nas preferências do SEU terminal (passo manual)."
    else
      warn "falha ao descompactar a fonte"
    fi
  else
    warn "não consegui baixar a fonte (rede?) — instale manualmente depois"
  fi
  rm -rf "$tmp"
}

# ---- 12. sincronizar plugins do LunarVim ----------------------------
sync_lvim_plugins() {
  step "Sincronizando plugins do LunarVim"

  if [ "${SKIP_LVIM_SYNC:-0}" = "1" ]; then
    warn "SKIP_LVIM_SYNC=1 — pulando :Lazy sync"
    return
  fi

  if ! have lvim; then
    warn "lvim não está no PATH — não consigo rodar :Lazy sync agora"
    return
  fi

  if lvim --headless -c "Lazy! sync" -c "qa" >/dev/null 2>&1; then
    ok "plugins sincronizados com o lazy-lock.json"
  else
    warn "não consegui rodar :Lazy sync em modo headless — abra o lvim e rode :Lazy sync manualmente"
  fi
}

# ---- 13. conexões do dadbod (esqueleto, sem senha) -------------------
setup_db_connections() {
  step "Preparando o arquivo de conexões do dadbod"
  local dir="$HOME/.config/dadbod" file="$dir/connections.env"
  mkdir -p "$dir"; chmod 700 "$dir"
  if [ ! -f "$file" ]; then
    cat > "$file" <<'ENVEOF'
# ============================================================
# Conexões de banco para o dadbod / LunarVim
# ============================================================
# chmod 600 · NÃO versionar (contém senhas).
# Convenção: cada variável DBUI_<Nome> vira uma conexão no lvim.
# O rótulo exibido é <Nome> com "_" trocado por espaço.
#
# Formatos:
#   mysql://usuario:senha@host:porta/banco       (precisa do cliente mysql)
#   postgresql://usuario:senha@host:porta/banco  (precisa do psql)
#   sqlserver://usuario:senha@host:porta/banco   (precisa do sqlcmd)
#   sqlite:/caminho/arquivo.db
#
# Senha com caractere especial => URL-encode (@ %40 · : %3A · / %2F ·
#   ? %3F · & %26 · % %25 · < %3C · > %3E · * %2A · espaço %20).
#
# Exemplo (descomente e ajuste):
# export DBUI_Meu_Banco_Local="mysql://root:senha@127.0.0.1:3306/meu_banco"
ENVEOF
    chmod 600 "$file"
    ok "criado (esqueleto): $file"
  else
    chmod 600 "$file"
    ok "já existe (mantido): $file"
  fi
  rc_add 'dadbod/connections.env' \
    '[ -f "$HOME/.config/dadbod/connections.env" ] && source "$HOME/.config/dadbod/connections.env"  # dadbod/LunarVim DB connections'
  ok "auto-load adicionado ao $RC"
}

# ---- 14. validação --------------------------------------------------
validate() {
  step "Validação final"
  local pad="%-14s"
  printf "$pad %s\n" "lvim"     "$(command -v lvim     || echo 'AUSENTE (abra um terminal novo)')"
  printf "$pad %s\n" "nvim"     "$(nvim --version 2>/dev/null | head -1 || echo AUSENTE)"
  printf "$pad %s\n" "mysql"    "$(command -v mysql    || echo AUSENTE)"
  printf "$pad %s\n" "black"    "$(command -v black    || echo AUSENTE)"
  printf "$pad %s\n" "prettier" "$(command -v prettier || echo AUSENTE)"
  printf "$pad %s\n" "lazygit"  "$(command -v lazygit  || echo AUSENTE)"
  printf "$pad %s\n" "config"   "$(readlink -f "$HOME/.config/lvim" 2>/dev/null || echo AUSENTE)"
  echo
  ok "Concluído."
  echo "Próximos passos:"
  echo "  1) Abra um terminal NOVO (ou rode: source \"$RC\")."
  echo "  2) APLIQUE a 'FiraCode Nerd Font' nas preferências do seu terminal (a fonte já foi instalada)."
  echo "  3) Edite ~/.config/dadbod/connections.env e adicione suas conexões (linhas DBUI_...)."
  echo "  4) Rode: lvim   (na 1ª vez ele baixa plugins e LSPs — aguarde)."
}

main() {
  step "Setup do LunarVim — repositório: $REPO_DIR"
  detect_os
  detect_rc
  install_base
  ensure_local_bin
  sync_config_repo "$@"
  install_db_client
  install_lunarvim
  link_config
  install_formatters
  install_lazygit
  install_nerd_font
  sync_lvim_plugins
  setup_db_connections
  validate
}

main "$@"
