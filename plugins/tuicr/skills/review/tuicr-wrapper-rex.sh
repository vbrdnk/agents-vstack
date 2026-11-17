#!/usr/bin/env bash
set -e -u -o pipefail

# Configuration - override via environment variables
TUICR_PANE_DIRECTION="${TUICR_PANE_DIRECTION:-right}"  # left, right, above or below
TUICR_PANE_SIZE="${TUICR_PANE_SIZE:-60}"                # percentage of the split
REX_BIN="${REX_BIN:-rex}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
  printf "%b[tuicr]%b %s\n" "$GREEN" "$NC" "$*"
}

log_warn() {
  printf "%b[tuicr]%b %s\n" "$YELLOW" "$NC" "$*"
}

log_error() {
  printf "%b[tuicr]%b %s\n" "$RED" "$NC" "$*" >&2
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [directory] [-- tuicr-args...]

Launch tuicr in a Rex split block and wait for it to exit.

Arguments:
  directory    Git or jj repository directory to review (default: current directory)
  tuicr-args   Extra arguments passed through to tuicr (e.g. -w, -r <revset>)

Environment variables:
  TUICR_PANE_DIRECTION  Split direction: left, right, above or below (default: right)
  TUICR_PANE_SIZE       Percentage of the split for the tuicr block (default: 60)
  REX_BIN               Path to the rex executable (default: rex)

Examples:
  $(basename "$0")
  $(basename "$0") ~/project
  $(basename "$0") . -- -w
  TUICR_PANE_DIRECTION=below $(basename "$0")
EOF
}

require_command() {
  if ! command -v "$1" &>/dev/null; then
    log_error "$2 not found on PATH"
    return 1
  fi
}

check_repo() {
  local dir="$1"
  if git -C "$dir" rev-parse --git-dir &>/dev/null; then
    return 0
  fi
  if command -v jj &>/dev/null \
    && jj --repository "$dir" --ignore-working-copy root &>/dev/null; then
    return 0
  fi
  log_error "Not a git or jj repository: $dir"
  return 1
}

temp_dir=""
split_pid=""

# Close the tuicr block if the wrapper is interrupted before tuicr exits.
cleanup() {
  local status=$?
  if [[ -n "$split_pid" ]] && kill -0 "$split_pid" 2>/dev/null; then
    local block_id
    block_id=$(grep -A1 '"block_ids"' "$temp_dir/split.json" 2>/dev/null \
      | grep -o 'block:[^"]*' | head -1 || true)
    if [[ -n "$block_id" ]]; then
      "$REX_BIN" block close "$block_id" >/dev/null 2>&1 || true
    fi
    kill "$split_pid" 2>/dev/null || true
  fi
  [[ -n "$temp_dir" ]] && rm -rf "$temp_dir"
  return "$status"
}

launch_tuicr_block() {
  local target_dir="$1"
  shift

  case "$TUICR_PANE_DIRECTION" in
    left|right|above|below) ;;
    *)
      log_warn "Unknown TUICR_PANE_DIRECTION '$TUICR_PANE_DIRECTION'; using 'right'"
      TUICR_PANE_DIRECTION="right"
      ;;
  esac

  temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/tuicr-rex.XXXXXX")
  local output_file="$temp_dir/output"
  : >"$output_file"

  local tuicr_bin
  tuicr_bin=$(command -v tuicr)

  local tuicr_cmd=("$tuicr_bin")
  local use_stdout=false
  if "$tuicr_bin" --help 2>&1 | grep -q -- '--stdout'; then
    tuicr_cmd+=(--stdout)
    use_stdout=true
  else
    log_warn "tuicr --stdout not supported, output will be copied to clipboard"
  fi
  tuicr_cmd+=("$@")

  # Redirect tuicr stdout to a file without a shell: bash -c receives the
  # command as positional args, so no quoting of user args is needed.
  local runner='out="$1"; shift; if [ -n "$out" ]; then exec "$@" >"$out"; else exec "$@"; fi'
  local out_arg=""
  [[ "$use_stdout" == true ]] && out_arg="$output_file"

  log_info "Launching tuicr in a Rex block split $TUICR_PANE_DIRECTION (${TUICR_PANE_SIZE}%)"
  log_info "Directory: $target_dir"

  # --wait prints the creation JSON, then blocks and returns tuicr's exit
  # status. Run it in the background so the trap can close the block.
  "$REX_BIN" split \
    --split "$TUICR_PANE_DIRECTION" \
    --ratio "$TUICR_PANE_SIZE" \
    --cwd "$target_dir" \
    --label tuicr \
    --shell none \
    --json \
    --wait \
    -- bash -c "$runner" tuicr-rex "$out_arg" "${tuicr_cmd[@]}" \
    >"$temp_dir/split.json" 2>"$temp_dir/split.err" &
  split_pid=$!

  log_info "Waiting for tuicr to exit..."
  local tuicr_status=0
  wait "$split_pid" || tuicr_status=$?
  split_pid=""

  if ! grep -q '"block_ids"' "$temp_dir/split.json" 2>/dev/null; then
    log_error "Rex could not create the tuicr block: $(cat "$temp_dir/split.err")"
    return 1
  fi

  if [[ "$tuicr_status" -ne 0 ]]; then
    log_error "tuicr exited with status $tuicr_status"
  else
    log_info "tuicr finished"
  fi

  if [[ "$use_stdout" == true ]]; then
    if [[ -s "$output_file" ]]; then
      echo ""
      echo "=== TUICR INSTRUCTIONS ==="
      cat "$output_file"
      echo "=== END TUICR INSTRUCTIONS ==="
    else
      log_info "No instructions exported from tuicr"
    fi
  else
    log_info "If you exported instructions, they are in your clipboard - paste them here"
  fi

  return "$tuicr_status"
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  if [[ -z "${REX_SESSION:-}" ]]; then
    log_error "Not running inside a Rex terminal"
    echo "Run your coding agent inside Rex, then invoke the tuicr skill again."
    exit 1
  fi

  require_command "$REX_BIN" "rex"
  require_command "tuicr" "tuicr"

  local target_dir="."
  if [[ "${1:-}" != "--" && -n "${1:-}" ]]; then
    target_dir="$1"
    shift
  fi
  if [[ "${1:-}" == "--" ]]; then
    shift
  fi
  if [[ ! -d "$target_dir" ]]; then
    log_error "Directory not found: $target_dir"
    exit 1
  fi
  target_dir=$(cd "$target_dir" && pwd)

  check_repo "$target_dir"

  trap cleanup EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM

  launch_tuicr_block "$target_dir" "$@"
}

main "$@"
