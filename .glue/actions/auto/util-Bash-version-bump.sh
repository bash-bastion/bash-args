#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap

action() {
	local newVersion="$1"
	ensure.nonZero 'newVersion' "$newVersion"

	# TODO: better output
	exec 8> >(xargs -r0 -- grep -l "PROGRAM_VERSION")
	find . -ignore_readdir_race -regex '\./pkg/.*\.\(sh\|bash\)' -print0 2>/dev/null \
		| tee /dev/fd/8 \
		| xargs -r0 -- sed -i -e "s|\(PROGRAM_VERSION=\"\).*\(\"\)|\1$newVersion\2|g"
	exec 8>&-

	wait
	log.info "util-Bash-version-bump: Bump done"
}

action "$@"
unbootstrap
