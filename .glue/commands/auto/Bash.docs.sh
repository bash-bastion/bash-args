#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

# glue useAction(tool-shdoc.sh)
util.get_action 'tool-shdoc.sh'
source "$REPLY"

unbootstrap
