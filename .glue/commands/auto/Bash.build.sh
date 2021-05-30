#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

# glue useAction(util-get-version.sh)
util.get_action 'util-get-version.sh'
source "$REPLY"
declare newVersion="$REPLY"

# glue useAction(util-Bash-version-bump.sh)
util.get_action 'util-Bash-version-bump.sh'
source "$REPLY" "$newVersion"

unbootstrap
