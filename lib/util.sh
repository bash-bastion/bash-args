#!/usr/bin/env bash

die() {
	log_error "${*-'die: '}. Exiting"
	exit 1
}

log_info() {
	rintf "\033[0;34m%s\033[0m\n" "Info: $*"
}

log_warn() {
	printf "\033[1;33m%s\033[0m\n" "Warn: $*" >&2
}

log_error() {
	printf "\033[0;31m%s\033[0m\n" "Error: $*" >&2
}
