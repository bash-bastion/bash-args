# shellcheck shell=bash

ARGS_ROOT_DIR="$(readlink -f "${BASH_SOURCE[0]}")"
ARGS_ROOT_DIR="${ARGS_ROOT_DIR%/*}"
ARGS_ROOT_DIR="${ARGS_ROOT_DIR%/*}"

source "$ARGS_ROOT_DIR/lib/args.sh"
source "$ARGS_ROOT_DIR/lib/args-do.sh"
