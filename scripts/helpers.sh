#!/usr/bin/env bash
# ============================================================================
# helpers.sh — funções comuns do instalador dev-env
# ============================================================================

# --- output ----------------------------------------------------------------
C_RESET='\033[0m'; C_GREEN='\033[1;32m'; C_RED='\033[1;31m'
C_YELLOW='\033[1;33m'; C_CYAN='\033[1;36m'; C_BOLD='\033[1m'

log()  { printf "${C_GREEN}[dev-env]${C_RESET} %s\n" "$*"; }
info() { printf "${C_CYAN}[dev-env]${C_RESET} %s\n" "$*"; }
warn() { printf "${C_YELLOW}[dev-env]${C_RESET} %s\n" "$*"; }
err()  { printf "${C_RED}[dev-env]${C_RESET} %s\n" "$*" >&2; }
die()  { err "$*"; exit 1; }

# --- prompts ---------------------------------------------------------------
# ask_yes "pergunta" [default: y|n] -> 0 (sim) / 1 (não)
ask_yes() {
  local question="$1" default="${2:-y}" ans
  local suffix
  [ "$default" = "y" ] && suffix="[Y/n]" || suffix="[y/N]"
  printf "${C_BOLD}%s${C_RESET} %s " "$question" "$suffix"
  read -r ans
  case "${ans:-$default}" in
    y|Y|s|S) return 0 ;;
    *) return 1 ;;
  esac
}

# --- detecção de caminhos --------------------------------------------------
sdkman_dir()   { printf '%s' "${SDKMAN_DIR:-$HOME/.sdkman}"; }
nvm_dir()      { printf '%s' "${NVM_DIR:-$HOME/.nvm}"; }
pi_node_dir()  { printf '%s' "$HOME/.local/share/pi-node"; }
dev_env_dir()  { printf '%s' "${DEV_ENV_DIR:-$HOME/.local/share/dev-env}"; }
bin_dir()      { printf '%s' "$HOME/.local/bin"; }

# --- verificação de binários ------------------------------------------------
have() { command -v "$1" >/dev/null 2>&1; }

# version_of <bin> -> versão ou "—"
version_of() {
  local bin="$1" out
  if ! have "$bin"; then echo "—"; return; fi
  out="$("$bin" --version 2>/dev/null | head -1)"
  echo "${out:-presente}"
}

# ensure_dir <dir>
ensure_dir() { mkdir -p "$1"; }

# --- paths absolutos de servidores LSP (desta instalação) -------------------
jdtls_wrapper()   { printf '%s/jdtls-wrapper' "$(bin_dir)"; }
jdtls_home()      { printf '%s/jdtls' "$HOME/.local/share"; }
tsserver_bin()    {
  # typescript-language-server instalado no node gerenciado (pi-node ou nvm)
  if [ -x "$HOME/.local/share/pi-node/"*/bin/typescript-language-server ] 2>/dev/null; then
    ls "$HOME/.local/share/pi-node/"*/bin/typescript-language-server 2>/dev/null | head -1
  elif have typescript-language-server; then
    command -v typescript-language-server
  else
    echo "typescript-language-server"
  fi
}

# --- config dirs de destino -------------------------------------------------
OMP_AGENT_DIR="$HOME/.omp/agent"
PI_AGENT_DIR="$HOME/.pi/agent"
