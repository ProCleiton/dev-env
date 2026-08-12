#!/usr/bin/env bash
# ============================================================================
# install-plugins.sh — marketplaces e plugins do harness omp
#   claude-plugins-official: code-review, security-guidance, commit-commands
#
# Uso: install-plugins.sh
# Requer: omp instalado (senão apenas informa os marketplaces).
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers.sh
. "$SCRIPT_DIR/helpers.sh"

MARKETPLACES=(
  "claude-plugins-official|anthropics/claude-plugins-official"
  "superpowers-marketplace|obra/superpowers-marketplace"
)
PLUGINS=(
  "code-review@claude-plugins-official"
  "security-guidance@claude-plugins-official"
  "commit-commands@claude-plugins-official"
)

main() {
  if ! have omp; then
    warn "omp não encontrado — pule a instalação de plugins ou instale o harness primeiro."
    warn "Marketplaces a registrar (manual): ${MARKETPLACES[*]}"
    return 0
  fi

  local spec src name
  for spec in "${MARKETPLACES[@]}"; do
    name="${spec%%|*}"; src="${spec#*|}"
    if omp marketplace list 2>/dev/null | grep -q "$name"; then
      log "Marketplace $name já registrado"
    else
      info "Registrando marketplace $name ($src)..."
      omp marketplace add "$src" || warn "Falha ao registrar $name (pode exigir flag --user)"
    fi
  done

  for p in "${PLUGINS[@]}"; do
    if omp plugin list 2>/dev/null | grep -q "$p"; then
      log "Plugin $p já instalado"
    else
      info "Instalando plugin $p..."
      omp plugin install "$p" || warn "Falha ao instalar $p"
    fi
  done
  log "Plugins OK"
}

main "$@"
