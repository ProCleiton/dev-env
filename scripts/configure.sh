#!/usr/bin/env bash
# ============================================================================
# configure.sh — instala/atualiza as configurações do ambiente
#
# Copia configs do repo para os destinos do harness (com backup do existente):
#   config/config.yml      -> ~/.omp/agent/config.yml
#   config/lsp.json        -> ~/.omp/agent/lsp.json   (path do tsserver resolvido)
#   config/mcp.json        -> ~/.omp/agent/mcp.json
#   config/settings.json   -> ~/.pi/agent/settings.json  (layer pi)
#   config/AGENTS.md       -> ~/.omp/agent/AGENTS.md
#   config/RULES.md        -> ~/.omp/agent/RULES.md
#   config/commands/*.md   -> ~/.omp/agent/commands/
#   config/skills/*        -> ~/.omp/agent/skills/
#   bin/mem                -> ~/.local/bin/mem
#
# Uso: configure.sh --source <repo_dir>
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers.sh
. "$SCRIPT_DIR/helpers.sh"

SOURCE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --source) SOURCE="${2:-}"; shift 2 ;;
    *) shift ;;
  esac
done
[ -n "$SOURCE" ] || SOURCE="$(dirname "$SCRIPT_DIR")"

TS="$(date +%Y%m%d-%H%M%S)"

backup() { # backup <arquivo>
  if [ -f "$1" ]; then
    cp -a "$1" "$1.bak-$TS"
  fi
}

install_file() { # install_file <origem> <destino> [chmod]
  ensure_dir "$(dirname "$2")"
  backup "$2"
  cp -a "$1" "$2"
  [ -n "${3:-}" ] && chmod "$3" "$2"
  log "config: $2"
}

main() {
  local cfg="$SOURCE/config"

  log "Configurando harness omp (~/.omp/agent)..."
  ensure_dir "$OMP_AGENT_DIR"
  install_file "$cfg/config.yml"        "$OMP_AGENT_DIR/config.yml"
  install_file "$cfg/AGENTS.md"         "$OMP_AGENT_DIR/AGENTS.md"
  install_file "$cfg/RULES.md"          "$OMP_AGENT_DIR/RULES.md"
  install_file "$cfg/mcp.json"          "$OMP_AGENT_DIR/mcp.json"

  # lsp.json com os paths reais (wrapper jdtls + tsserver)
  ensure_dir "$OMP_AGENT_DIR"
  backup "$OMP_AGENT_DIR/lsp.json"
  sed -e "s|@TSSERVER_PATH@|$(tsserver_bin)|g" \
      -e "s|@JDTLS_WRAPPER@|$(jdtls_wrapper)|g" \
      "$cfg/lsp.json" > "$OMP_AGENT_DIR/lsp.json"
  log "config: $OMP_AGENT_DIR/lsp.json (tsserver -> $(tsserver_bin), jdtls -> $(jdtls_wrapper))"

  # commands e skills
  if [ -d "$cfg/commands" ]; then
    ensure_dir "$OMP_AGENT_DIR/commands"
    for f in "$cfg"/commands/*; do
      [ -f "$f" ] && install_file "$f" "$OMP_AGENT_DIR/commands/$(basename "$f")"
    done
  fi
  if [ -d "$cfg/skills" ]; then
    for d in "$cfg"/skills/*/; do
      [ -d "$d" ] || continue
      ensure_dir "$OMP_AGENT_DIR/skills/$(basename "$d")"
      for f in "$d"*; do
        [ -f "$f" ] && install_file "$f" "$OMP_AGENT_DIR/skills/$(basename "$d")/$(basename "$f")"
      done
    done
  fi

  log "Configurando layer pi (~/.pi/agent)..."
  ensure_dir "$PI_AGENT_DIR"
  install_file "$cfg/settings.json" "$PI_AGENT_DIR/settings.json"

  log "Instalando binários locais (~/.local/bin)..."
  ensure_dir "$(bin_dir)"
  install_file "$SOURCE/bin/mem" "$(bin_dir)/mem" 755
  # wrapper jdtls (se o jdtls já existir)
  if [ -d "$(jdtls_home)/bin" ] && [ ! -x "$(jdtls_wrapper)" ]; then
    ensure_dir "$(bin_dir)"
    bash "$SCRIPT_DIR/install-lsp.sh" --jdtls || warn "wrapper jdtls não gerado (jdtls ausente?)"
  fi

  log "Configuração concluída. Backups: *.bak-$TS nos destinos."
  info "Variáveis de ambiente pendentes: rode 'dev-env env' para ver o template (.bashrc)."
}

main "$@"
