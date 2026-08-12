#!/usr/bin/env bash
# ============================================================================
# install.sh — instalador principal do dev-env
#
# Uso (bootstrap): curl -fsSL .../install.sh | bash [flags]
# Uso (direto):    scripts/install.sh --source <repo_dir> [flags]
#
# Flags:
#   --verify-only        apenas verifica o ambiente (não altera nada)
#   --configure-only     apenas aplica as configurações
#   --no-plugins         pula marketplaces/plugins
#   --no-langs           pula SDKMAN/nvm/bun
#   --no-lsp             pula servidores LSP
#   --yes / -y           não pergunta confirmações
#   --source <dir>       diretório do repo (bootstrap já passa)
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers.sh
. "$SCRIPT_DIR/helpers.sh"

SOURCE=""
DO_LANGS=1; DO_LSP=1; DO_PLUGINS=1; DO_CONFIGURE=1; DO_VERIFY=1
ASSUME_YES=0

while [ $# -gt 0 ]; do
  case "$1" in
    --source) SOURCE="${2:-}"; shift 2 ;;
    --verify-only) DO_LANGS=0; DO_LSP=0; DO_PLUGINS=0; DO_CONFIGURE=0; shift ;;
    --configure-only) DO_VERIFY=0; DO_LANGS=0; DO_LSP=0; DO_PLUGINS=0; shift ;;
    --no-plugins) DO_PLUGINS=0; shift ;;
    --no-langs) DO_LANGS=0; shift ;;
    --no-lsp) DO_LSP=0; shift ;;
    --yes|-y) ASSUME_YES=1; shift ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//' | head -40
      exit 0 ;;
    *) warn "Argumento ignorado: $1"; shift ;;
  esac
done

[ -n "$SOURCE" ] || SOURCE="$(dirname "$SCRIPT_DIR")"

log "dev-env — instalador do ambiente de desenvolvimento (fonte: $SOURCE)"

if [ "$DO_VERIFY" = "1" ]; then
  echo
  bash "$SCRIPT_DIR/verify.sh"
fi

if [ "$DO_LANGS" = "1" ] || [ "$DO_LSP" = "1" ] || [ "$DO_PLUGINS" = "1" ]; then
  echo
  log "Componentes a instalar: langs=$DO_LANGS lsp=$DO_LSP plugins=$DO_PLUGINS"
  if [ "$ASSUME_YES" != "1" ]; then
    ask_yes "Continuar com a instalação?" "y" || die "Abortado pelo usuário."
  fi
fi

[ "$DO_LANGS" = "1" ]   && { echo; bash "$SCRIPT_DIR/install-langs.sh" --all; }
[ "$DO_LSP" = "1" ]     && { echo; bash "$SCRIPT_DIR/install-lsp.sh" --all; }
[ "$DO_PLUGINS" = "1" ] && { echo; bash "$SCRIPT_DIR/install-plugins.sh"; }
[ "$DO_CONFIGURE" = "1" ] && { echo; bash "$SCRIPT_DIR/configure.sh" --source "$SOURCE"; }

# instala o CLI dev-env
ensure_dir "$(bin_dir)"
cp -a "$SOURCE/scripts/dev-env" "$(bin_dir)/dev-env"
chmod 755 "$(bin_dir)/dev-env"

echo
log "Instalação concluída."
info "Comandos: dev-env verify | dev-env status | dev-env env | dev-env update"
info "Para ativar SDKMAN/nvm no shell atual: source ~/.bashrc"
