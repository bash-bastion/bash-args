#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

unset main
main() {
	local newVersion="$1"
	ensure.nonZero 'newVersion' "$newVersion"

	# TODO: show which files changed
	find . -ignore_readdir_race -regex '\./pkg/.*\.\(sh\|bash\)' -print0 2>/dev/null \
		| xargs -r0 \
		sed -i -e "s|\(PROGRAM_VERSION=\"\).*\(\"\)|\1$newVersion\2|g"
	log.info "util-Bash-version-bump: Bump done"
}

main "$@"
unset main

unbootstrap
