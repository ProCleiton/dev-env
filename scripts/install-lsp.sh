#!/usr/bin/env bash
# ============================================================================
# install-lsp.sh — servidores LSP do ambiente
#   jdtls (Eclipse JDT LS) + typescript-language-server
#
# Uso: install-lsp.sh [--jdtls | --tsserver | --all]
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers.sh
. "$SCRIPT_DIR/helpers.sh"

JDTLS_URL="${JDTLS_URL:-https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz}"
JAVA_HOME_DEFAULT="${JAVA_HOME_DEFAULT:-$HOME/.sdkman/candidates/java/21.0.5-zulu}"
MODE="${1:---all}"

install_jdtls() {
  local dest jdtls_bin
  dest="$(jdtls_home)"
  jdtls_bin="$(jdtls_wrapper)"

  if [ -x "$jdtls_bin" ] && [ -d "$dest/plugins" ]; then
    log "jdtls já instalado em $dest"
    return 0
  fi
  for t in curl tar python3; do
    have "$t" || die "Ferramenta necessária ausente: $t"
  done
  if [ ! -d "$JAVA_HOME_DEFAULT" ]; then
    warn "JVM $JAVA_HOME_DEFAULT não encontrada — jdtls exige Java 21+. Instale via: dev-env install --langs"
  fi

  log "Baixando jdtls (~50 MB)..."
  ensure_dir "$dest"
  curl -fsSL "$JDTLS_URL" -o "$dest/jdtls.tar.gz" || die "Falha no download do jdtls"
  tar -xzf "$dest/jdtls.tar.gz" -C "$dest"
  rm -f "$dest/jdtls.tar.gz"

  # wrapper: fixa JAVA_HOME (ServerConfig do omp não tem campo env)
  cat > "$jdtls_bin" <<EOF
#!/usr/bin/env bash
export JAVA_HOME="\${JDTLS_JAVA_HOME:-$JAVA_HOME_DEFAULT}"
exec "$dest/bin/jdtls" "\$@"
EOF
  chmod +x "$jdtls_bin"
  log "jdtls instalado. Wrapper: $jdtls_bin"
}

install_tsserver() {
  if have typescript-language-server; then
    log "typescript-language-server já instalado ($(typescript-language-server --version 2>/dev/null))"
    return 0
  fi
  have npm || die "npm é necessário para typescript-language-server"
  log "Instalando typescript-language-server via npm (global)..."
  npm install -g typescript-language-server typescript
  log "typescript-language-server instalado em $(command -v typescript-language-server)"
}

main() {
  case "$MODE" in
    --jdtls) install_jdtls ;;
    --tsserver) install_tsserver ;;
    --all) install_jdtls; install_tsserver ;;
    *) die "Uso: install-lsp.sh [--jdtls|--tsserver|--all]" ;;
  esac
  log "Servidores LSP OK. Configure com: dev-env configure"
}

main "$@"
