#!/usr/bin/env bash
# ============================================================================
# dev-env installer bootstrap
#
# Instala o ambiente de desenvolvimento autocontido (como o oh-my-pi):
#   curl -fsSL https://raw.githubusercontent.com/ProCleiton/dev-env/main/install.sh | bash
#
# Fluxo:
#   1. Baixa o tarball do repositório (ou usa --local <dir> em desenvolvimento)
#   2. Extrai em ${DEV_ENV_DIR:-$HOME/.local/share/dev-env}
#   3. Executa scripts/install.sh com os mesmos argumentos
# ============================================================================
set -euo pipefail

REPO="ProCleiton/dev-env"
BRANCH="main"
DEST="${DEV_ENV_DIR:-$HOME/.local/share/dev-env}"
TARBALL_URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"

log()  { printf '\033[1;32m[dev-env]\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m[dev-env]\033[0m %s\n' "$*" >&2; }

# --local <dir>: usa uma cópia local do repo (sem download)
LOCAL_SRC=""
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --local) LOCAL_SRC="${2:-}"; shift 2 ;;
    *) ARGS+=("$1"); shift ;;
  esac
done

if [ -n "$LOCAL_SRC" ]; then
  SRC="$(cd "$LOCAL_SRC" && pwd)"
  log "Usando fonte local: $SRC"
  if [ ! -x "$SRC/scripts/install.sh" ]; then
    err "scripts/install.sh não encontrado em $SRC"
    exit 1
  fi
  exec bash "$SRC/scripts/install.sh" --source "$SRC" "${ARGS[@]}"
fi

# Checagens mínimas para bootstrap
for tool in curl tar; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    err "Ferramenta necessária ausente: $tool"
    exit 1
  fi
done

log "Baixando dev-env (${REPO}@${BRANCH})..."
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
if ! curl -fsSL "$TARBALL_URL" -o "$TMP/dev-env.tar.gz"; then
  err "Falha ao baixar $TARBALL_URL"
  exit 1
fi

log "Extraindo para $DEST..."
mkdir -p "$DEST"
tar -xzf "$TMP/dev-env.tar.gz" -C "$TMP"
EXTRACTED="$TMP/dev-env-${BRANCH}"
[ -d "$EXTRACTED" ] || EXTRACTED="$(find "$TMP" -maxdepth 1 -type d -name 'dev-env-*' | head -1)"
if [ -z "$EXTRACTED" ] || [ ! -f "$EXTRACTED/scripts/install.sh" ]; then
  err "Conteúdo inesperado no tarball; instalação abortada."
  exit 1
fi

log "Executando instalador..."
exec bash "$EXTRACTED/scripts/install.sh" --source "$EXTRACTED" "${ARGS[@]}"
