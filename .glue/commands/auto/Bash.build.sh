#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

# glue useAction(util-release-pre.sh)
util.get_action 'util-release-pre.sh'
source "$REPLY" 'dry'
newVersion="$REPLY"

sed -ie "s|\(version[ \t]*=[ \t]*\"\).*\(\"\)|\1${newVersion}\2|g" glue-auto.toml

unbootstrap
