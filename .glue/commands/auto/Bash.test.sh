#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

# glue useAction(tool-bats.sh)
util.get_action 'tool-bats.sh'
source "$REPLY"

unbootstrap
