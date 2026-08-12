#!/usr/bin/env bash
# ============================================================================
# install-langs.sh — gerenciadores de versão e runtimes
#   SDKMAN (Java) · nvm (Node) · bun (runtime do omp) · node gerenciado (pi)
#
# Uso: install-langs.sh [--java | --node | --bun | --all]
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers.sh
. "$SCRIPT_DIR/helpers.sh"

JAVA_VERSIONS="${JAVA_VERSIONS:-8.0.432-zulu 17.0.13-zulu 21.0.5-zulu 25.0.3-zulu}"
NODE_VERSION="${NODE_VERSION:-22.11.0}"
MODE="${1:---all}"

install_sdkman() {
  local sdk="${SDKMAN_DIR:-$HOME/.sdkman}"
  if [ -d "$sdk" ]; then
    log "SDKMAN já instalado em $sdk"
    return 0
  fi
  if ! have curl; then die "curl é necessário para instalar o SDKMAN"; fi
  log "Instalando SDKMAN..."
  curl -fsSL "https://get.sdkman.io" | bash
  # shellcheck disable=SC1091
  [ -s "$sdk/bin/sdkman-init.sh" ] && . "$sdk/bin/sdkman-init.sh" || die "Falha ao inicializar SDKMAN"
}

install_java() {
  install_sdkman
  # shellcheck disable=SC1091
  [ -f "$(sdkman_dir)/bin/sdkman-init.sh" ] && . "$(sdkman_dir)/bin/sdkman-init.sh"
  local v
  for v in $JAVA_VERSIONS; do
    if [ -d "$(sdkman_dir)/candidates/java/$v" ]; then
      log "Java $v já instalado"
      continue
    fi
    info "Instalando Java $v (pode demorar)..."
    sdk install java "$v" < /dev/null || warn "Falha ao instalar Java $v (verifique disponibilidade no SDKMAN)"
  done
}

install_nvm() {
  local nvm="${NVM_DIR:-$HOME/.nvm}"
  if [ -d "$nvm" ]; then
    log "nvm já instalado em $nvm"
    return 0
  fi
  log "Instalando nvm..."
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh" | bash
}

install_node_nvm() {
  install_nvm
  # shellcheck disable=SC1091
  [ -s "$(nvm_dir)/nvm.sh" ] && . "$(nvm_dir)/nvm.sh"
  if [ -d "$(nvm_dir)/versions/node/v$NODE_VERSION" ]; then
    log "Node v$NODE_VERSION já instalado"
    return 0
  fi
  info "Instalando Node v$NODE_VERSION via nvm..."
  nvm install "$NODE_VERSION" < /dev/null || warn "Falha ao instalar Node v$NODE_VERSION"
}

install_bun() {
  if have bun; then
    log "bun já instalado ($(bun --version 2>/dev/null))"
    return 0
  fi
  log "Instalando bun..."
  curl -fsSL "https://bun.sh/install" | bash
}

main() {
  case "$MODE" in
    --java) install_java ;;
    --node) install_node_nvm ;;
    --bun) install_bun ;;
    --all)
      install_bun
      install_sdkman
      install_java
      install_nvm
      install_node_nvm
      ;;
    *) die "Uso: install-langs.sh [--java|--node|--bun|--all]" ;;
  esac
  log "Runtimes OK. Reabra o shell para ativar SDKMAN/nvm (ou: source ~/.sdkman/bin/sdkman-init.sh)."
}

main "$@"
