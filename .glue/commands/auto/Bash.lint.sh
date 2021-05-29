#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

# glue useAction(tool-shellcheck.sh)
util.get_action 'tool-shellcheck.sh'
source "$REPLY"

# glue useAction(tool-shellharden.sh)
# util.get_action 'tool-shellharden.sh'
# source "$REPLY"

unbootstrap
