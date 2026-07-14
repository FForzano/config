#!/usr/bin/env bash
set -uo pipefail

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Paths ────────────────────────────────────────────────────────────────────
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$REPO_ROOT/install.json"
SECRETS_FILE="$REPO_ROOT/secrets.json"

# ─── Secrets ──────────────────────────────────────────────────────────────────
SECRETS=""
if [ -f "$SECRETS_FILE" ]; then
  SECRETS="$(cat "$SECRETS_FILE")"
fi

# ─── Helpers ──────────────────────────────────────────────────────────────────
detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)  echo "linux" ;;
    *)      echo "unknown" ;;
  esac
}

expand() {
  local p="${1/#\~/$HOME}"
  echo "${p//\{ROOT\}/$REPO_ROOT}"
}

ask() {
  local response
  while true; do
    printf "${YELLOW}  Install %s? [y/n]: ${NC}" "$1"
    read -r response
    case "$response" in
      [yY]) return 0 ;;
      [nN]) return 1 ;;
      *)    echo "    Please answer 'y' or 'n'." ;;
    esac
  done
}

# ─── Status check ─────────────────────────────────────────────────────────────
# Returns 0 if the component is fully configured, 1 otherwise.
# Rules:
#   - link     → dst must be a symlink pointing to the exact src absolute path
#   - generate → dst file must exist and be non-empty
#   - shell    → if "check" is present, run it; if absent, treat as unverifiable
component_configured() {
  local component="$1"
  local action_count type src dst check_cmd
  local has_checkable=false
  local has_uncheckable_shell=false
  local all_ok=true

  action_count="$(echo "$component" | jq '.actions | length')"

  for j in $(seq 0 $((action_count - 1))); do
    action="$(echo "$component" | jq -c ".actions[$j]")"
    type="$(echo  "$action"    | jq -r '.type')"

    case "$type" in
      link)
        has_checkable=true
        src="$(expand "$(echo "$action" | jq -r '.src')")"
        [[ "$src" != /* ]] && src="$REPO_ROOT/$src"
        dst="$(expand "$(echo "$action" | jq -r '.dst')")"
        if [ ! -L "$dst" ] || [ "$(readlink "$dst")" != "$src" ]; then
          all_ok=false
        fi
        ;;
      generate)
        has_checkable=true
        dst="$(expand "$(echo "$action" | jq -r '.dst')")"
        if [ ! -s "$dst" ]; then
          all_ok=false
        fi
        ;;
      shell)
        local os_cmd
        os_cmd="$(echo "$action" | jq -r --arg os "$CURRENT_OS" '
          if .cmd | type == "object" then .cmd[$os] // empty else .cmd end')"
        # If no cmd for this OS, action doesn't apply — skip entirely
        [ -z "$os_cmd" ] && continue
        check_cmd="$(echo "$action" | jq -r '.check // empty')"
        if [ -n "$check_cmd" ]; then
          has_checkable=true
          if ! bash -c "$(expand "$check_cmd")" &>/dev/null; then
            all_ok=false
          fi
        else
          has_uncheckable_shell=true
        fi
        ;;
    esac
  done

  [ "$has_uncheckable_shell" = true ] && return 1
  [ "$has_checkable" = true ] && [ "$all_ok" = true ] && return 0
  return 1
}

# ─── Actions ──────────────────────────────────────────────────────────────────
action_link() {
  local src dst dst_dir
  src="$(expand "$1")"
  [[ "$src" != /* ]] && src="$REPO_ROOT/$src"
  dst="$(expand "$2")"
  dst_dir="$(dirname "$dst")"

  if [ ! -e "$src" ]; then
    echo -e "  ${RED}✗ source not found: $src${NC}"
    return 1
  fi

  mkdir -p "$dst_dir"

  if [ -L "$dst" ]; then
    echo -e "  ${BLUE}↩ already linked: $dst${NC}"
    return 0
  fi

  if [ -e "$dst" ]; then
    local backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$backup"
    echo -e "  ${YELLOW}⚠ backup created: $backup${NC}"
  fi

  ln -sf "$src" "$dst"
  echo -e "  ${GREEN}✓ linked:${NC} $(basename "$src") → $dst"
}

action_mkdir() {
  local path mode
  path="$(expand "$1")"
  mode="$2"

  mkdir -p "$path"
  [ -n "$mode" ] && chmod "$mode" "$path"
  echo -e "  ${GREEN}✓ directory:${NC} $path"
}

action_shell() {
  local cmd
  cmd="$(expand "$1")"
  echo -e "  ${CYAN}$ $cmd${NC}"
  if bash -c "$cmd"; then
    echo -e "  ${GREEN}✓ done${NC}"
  else
    echo -e "  ${RED}✗ command failed (exit $?)${NC}"
  fi
}

# Generates a file by repeating a template for each item in a secrets.json array.
# Each {{key}} in the template is replaced with the matching field from the item.
# {{key|prefix}} is conditional: if the item has a non-empty value for `key`,
# it's replaced with "prefix"+value; otherwise the whole placeholder is dropped
# (leaving an empty line), which lets a template declare optional directives.
action_generate() {
  local from_key item_template dst dst_dir count output block pair key value item sed_value

  dst="$(expand "$1")"
  from_key="$2"
  # printf '%b' interprets \n and other escape sequences from the JSON template string
  item_template="$(printf '%b' "$3")"
  dst_dir="$(dirname "$dst")"

  if [ -z "$SECRETS" ]; then
    echo -e "  ${RED}✗ secrets.json not found — copy secrets.example.json and fill in values${NC}"
    return 1
  fi

  count="$(echo "$SECRETS" | jq "(.${from_key} // []) | length")"

  if [ "$count" -eq 0 ]; then
    echo -e "  ${YELLOW}⚠ no entries found for '${from_key}' in secrets.json — skipping${NC}"
    return 0
  fi

  output=""
  for idx in $(seq 0 $((count - 1))); do
    item="$(echo "$SECRETS" | jq -c ".${from_key}[$idx]")"
    block="$item_template"
    while IFS= read -r pair; do
      key="${pair%%=*}"
      value="${pair#*=}"
      block="${block//\{\{$key\}\}/$value}"
      if [ -n "$value" ]; then
        # escape backslash, & and / so they're safe inside a sed replacement
        sed_value="${value//\\/\\\\}"
        sed_value="${sed_value//&/\\&}"
        sed_value="${sed_value//\//\\/}"
        block="$(printf '%s' "$block" | sed -E "s/\{\{${key}\|([^}]*)\}\}/\1${sed_value}/g")"
      fi
    done < <(echo "$item" | jq -r 'to_entries[] | "\(.key)=\(.value)"')
    # any {{key}} or {{key|prefix}} left over belongs to an optional field
    # absent (or empty) in this item — drop it, leaving an empty line
    block="$(echo "$block" | sed -E 's/\{\{[a-zA-Z0-9_]+\|[^}]*\}\}//g; s/\{\{[a-zA-Z0-9_]+\}\}//g')"
    output="${output}${block}"$'\n'
  done

  mkdir -p "$dst_dir"

  if [ -f "$dst" ]; then
    local backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
    cp "$dst" "$backup"
    echo -e "  ${YELLOW}⚠ backup created: $backup${NC}"
  fi

  printf '%s' "$output" > "$dst"
  echo -e "  ${GREEN}✓ generated:${NC} $dst ($count items)"
}

# ─── Main ─────────────────────────────────────────────────────────────────────
if ! command -v jq &>/dev/null; then
  echo -e "${RED}Error: jq not found. Install it with:${NC}  brew install jq"
  exit 1
fi

CURRENT_OS="$(detect_os)"

echo -e ""
echo -e "${BOLD}╔══════════════════════════════════════╗${NC}"
echo -e "${BOLD}║        Configuration installer            ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════╝${NC}"
echo -e "  OS:         ${CYAN}$CURRENT_OS${NC}"
echo -e "  Repository: ${CYAN}$REPO_ROOT${NC}"

if [ -n "$SECRETS" ]; then
  echo -e "  Secrets:    ${GREEN}secrets.json loaded${NC}"
else
  echo -e "  Secrets:    ${YELLOW}secrets.json not found — components requiring secrets will be skipped${NC}"
fi
echo -e ""

INSTALLED=0
SKIPPED=0
ALREADY=0
TOTAL="$(jq '.components | length' "$CONFIG_FILE")"

for i in $(seq 0 $((TOTAL - 1))); do
  component="$(jq -c ".components[$i]" "$CONFIG_FILE")"

  name="$(echo "$component" | jq -r '.name')"
  desc="$(echo "$component" | jq -r '.description')"

  os_match="$(echo "$component" | jq -r --arg os "$CURRENT_OS" \
    '.os | map(select(. == $os)) | length > 0')"

  echo -e "──────────────────────────────────────────"
  echo -e "${BOLD}[$name]${NC}  $desc"

  if [ "$os_match" = "false" ]; then
    echo -e "  ${BLUE}— not available on $CURRENT_OS, skipping${NC}"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  if component_configured "$component"; then
    echo -e "  ${GREEN}✓ already configured — skipping${NC}"
    ALREADY=$((ALREADY + 1))
    continue
  fi

  if ! ask "$name"; then
    echo -e "  skipped."
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  action_count="$(echo "$component" | jq '.actions | length')"

  for j in $(seq 0 $((action_count - 1))); do
    action="$(echo "$component" | jq -c ".actions[$j]")"
    type="$(echo  "$action"    | jq -r '.type')"

    case "$type" in
      link)
        src="$(echo "$action" | jq -r '.src')"
        dst="$(echo "$action" | jq -r '.dst')"
        action_link "$src" "$dst"
        ;;
      mkdir)
        path="$(echo "$action" | jq -r '.path')"
        mode="$(echo "$action" | jq -r '.mode // empty')"
        action_mkdir "$path" "$mode"
        ;;
      shell)
        cmd="$(echo "$action" | jq -r --arg os "$CURRENT_OS" '
          if .cmd | type == "object" then .cmd[$os] // empty else .cmd end')"
        [ -z "$cmd" ] && continue
        check_cmd="$(echo "$action" | jq -r '.check // empty')"
        if [ -n "$check_cmd" ] && bash -c "$(expand "$check_cmd")" &>/dev/null; then
          echo -e "  ${BLUE}↩ already done — skipping${NC}"
        else
          action_shell "$cmd"
        fi
        ;;
      generate)
        dst="$(echo   "$action" | jq -r '.dst')"
        from="$(echo  "$action" | jq -r '.from')"
        tmpl="$(echo  "$action" | jq -r '.template')"
        action_generate "$dst" "$from" "$tmpl"
        ;;
      *)
        echo -e "  ${RED}✗ unknown action type: $type${NC}"
        ;;
    esac
  done

  INSTALLED=$((INSTALLED + 1))
done

echo -e "══════════════════════════════════════════"
echo -e "${BOLD}Installed: ${GREEN}$INSTALLED${NC}  ${BOLD}Already configured: ${CYAN}$ALREADY${NC}  ${BOLD}Skipped: ${YELLOW}$SKIPPED${NC}"
echo -e ""
