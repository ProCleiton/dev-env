#!/usr/bin/env bash
# ============================================================================
# verify.sh — verificação de ambiente do dev-env
#
# Uso: verify.sh [--json]
# Checa SO/arquitetura, ferramentas, gerenciadores de versão, servidores LSP
# e componentes do harness. Saída: tabela legível (ou JSON com --json).
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=helpers.sh
. "$SCRIPT_DIR/helpers.sh"

JSON="${1:-}"

os_check() {
  local os arch
  os="$(uname -s)"; arch="$(uname -m)"
  [ "$os" = "Linux" ] || warn "SO não testado: $os (Linux é o alvo principal)"
  case "$arch" in
    x86_64|aarch64) : ;;
    *) warn "Arquitetura não testada: $arch" ;;
  esac
}

check() { # check <nome> <status> <detalhe>
  if [ "$JSON" = "--json" ]; then
    printf '{"name":%s,"ok":%s,"detail":%s}\n' \
      "$(printf '%s' "$1" | jq -R . 2>/dev/null || printf '"%s"' "$1")" \
      "$2" \
      "$(printf '%s' "$3" | jq -R . 2>/dev/null || printf '"%s"' "$3")"
  else
    local mark
    [ "$2" = "true" ] && mark="${C_GREEN}OK${C_RESET}" || mark="${C_RED}—${C_RESET}"
    printf '  %-32s %b  %s\n' "$1" "$mark" "$3"
  fi
}

main() {
  if [ "$JSON" != "--json" ]; then
    printf "${C_BOLD}dev-env — verificação de ambiente${C_RESET}\n"
    os_check
    printf "${C_BOLD}  Ferramentas base:${C_RESET}\n"
  fi

  local j=0
  while IFS='|' read -r name ok detail; do
    check "$name" "$ok" "$detail"
  done < <(
    # Ferramentas base
    for t in curl git tar bash python3 jq bun npm node; do
      if have "$t"; then echo "$t|true|$(version_of "$t")"; else echo "$t|false|ausente"; fi
    done
  )

  [ "$JSON" != "--json" ] && printf "${C_BOLD}  Gerenciadores de versão:${C_RESET}\n"
  while IFS='|' read -r name ok detail; do
    check "$name" "$ok" "$detail"
  done < <(
    if [ -d "$(sdkman_dir)" ]; then
      echo "sdkman|true|$(ls "$(sdkman_dir)"/candidates/java 2>/dev/null | grep -v '^current$' | tr '\n' ' ')"
    else
      echo "sdkman|false|ausente (Java)"
    fi
    if [ -d "$(nvm_dir)" ]; then
      echo "nvm|true|$(ls "$(nvm_dir)"/versions/node 2>/dev/null | tr '\n' ' ')"
    else
      echo "nvm|false|ausente (Node)"
    fi
    if [ -d "$(pi_node_dir)" ]; then
      echo "pi-node|true|$(ls "$(pi_node_dir)" | grep '^node-v' | tr '\n' ' ')"
    else
      echo "pi-node|false|ausente (node gerenciado do pi)"
    fi
  )

  [ "$JSON" != "--json" ] && printf "${C_BOLD}  Harness:${C_RESET}\n"
  while IFS='|' read -r name ok detail; do
    check "$name" "$ok" "$detail"
  done < <(
    if have omp; then echo "omp|true|$(omp --version 2>/dev/null | head -1)"; else echo "omp|false|ausente (bun i -g @oh-my-pi/pi-coding-agent)"; fi
    if have pi; then echo "pi|true|$(pi --version 2>/dev/null)"; else echo "pi|false|ausente (npm i -g @earendil-works/pi-coding-agent)"; fi
    if have mem; then echo "mem|true|presente"; else echo "mem|false|ausente (instalado pelo dev-env)"; fi
    if [ -f "$OMP_AGENT_DIR/config.yml" ]; then echo "config.yml|true|$(printf '%d linhas' "$(wc -l < "$OMP_AGENT_DIR/config.yml")")"; else echo "config.yml|false|ausente"; fi
    if [ -f "$OMP_AGENT_DIR/lsp.json" ]; then echo "lsp.json|true|$(jq -r '.servers | keys | join(",")' "$OMP_AGENT_DIR/lsp.json" 2>/dev/null)"; else echo "lsp.json|false|ausente"; fi
  )

  [ "$JSON" != "--json" ] && printf "${C_BOLD}  Servidores LSP:${C_RESET}\n"
  while IFS='|' read -r name ok detail; do
    check "$name" "$ok" "$detail"
  done < <(
    local jdtls_bin
    jdtls_bin="$(jdtls_wrapper)"
    if [ -x "$jdtls_bin" ]; then
      echo "jdtls|true|wrapper + $(basename "$(ls "$(jdtls_home)"/plugins/org.eclipse.jdt.ls.core_*.jar 2>/dev/null | head -1)" 2>/dev/null)"
    else
      echo "jdtls|false|ausente (instalar via dev-env install --lsp)"
    fi
    if have typescript-language-server; then echo "typescript-language-server|true|$(typescript-language-server --version 2>/dev/null)"; else echo "typescript-language-server|false|ausente"; fi
    if have rust-analyzer; then echo "rust-analyzer|true|$(rust-analyzer --version 2>/dev/null)"; else echo "rust-analyzer|false|ausente"; fi
  )
}

main "$@"
