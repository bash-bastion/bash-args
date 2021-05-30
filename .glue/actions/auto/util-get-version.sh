#!/usr/bin/env bash

unset main
main() {
	# If the working tree is dirty and there are unstaged changes
	# for both tracked and untracked files
	local dirty=
	if [ -n "$(git status --porcelain)" ]; then
		dirty=yes
	fi

	# Get the most recent Git tag that specifies a version
	local version
	if version="$(git describe --match 'v*' --abbrev=0 2>/dev/null)"; then
		version="${version/#v/}"
	else
		version="0.0.0"
	fi

	local id="$(git rev-parse --short HEAD)"
	version+="+$id${dirty:+-DIRTY}"
	REPLY="$version"
}

main "$@"
unset main
