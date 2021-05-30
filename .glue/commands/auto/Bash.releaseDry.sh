#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

# glue useAction(util-release-pre.sh)
util.get_action 'util-release-pre.sh'
source "$REPLY" 'dry'
newVersion="$REPLY"

# Bash version bump
(
	find . -ignore_readdir_race -regex '\./pkg/.*\.\(sh\|bash\)' -print0 \
		| xargs -r0 \
		sed -i -e "s|\(PROGRAM_VERSION=\"\).*\(\"\)|\1${newVersion}\2|g" || :
) || exit

# glue useAction(util-release-post.sh)
util.get_action 'util-release-post.sh'
source "$REPLY" 'dry' "$newVersion"

# glue useAction(result-pacman-package.sh)
util.get_action 'result-pacman-package.sh'
source "$REPLY"

unset newVersion

unbootstrap
