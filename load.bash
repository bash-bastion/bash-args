# shellcheck shell=bash

basalt_load() {
	for f in "$BASALT_PACKAGE_PATH"/pkg/{lib/util,source}/?*.sh; do
		source "$f"
	done; unset f
}
