#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

# glue useAction(util-release-pre.sh)
util.get_action 'util-release-pre.sh'
source "$REPLY"
newVersion="$REPLY"

# TODO: generalize
sed -i -e "s|\(PROGRAM_VERSION=\"\).*\(\"\)|\1${newVersion}\2|g" glue.sh || :

# glue useAction(util-release-post.sh)
util.get_action 'util-release-post.sh'
source "$REPLY" "$newVersion"

# glue useAction(tool-makepkg.sh)
util.get_action 'tool-makepkg.sh'
source "$REPLY"

unset newVersion
unbootstrap
