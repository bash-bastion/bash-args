#!/usr/bin/env bash
eval "$GLUE_COMMANDS_BOOTSTRAP"
bootstrap || exit

# glue useAction(do-tool-bats.sh)
util.get_action 'do-tool-bats.sh'
source "$REPLY"

# glue useAction(do-tool-shellcheck.sh)
util.get_action 'do-tool-shellcheck.sh'
source "$REPLY"

# glue useAction(do-tool-shellharden.sh)
# util.get_action 'do-tool-shellharden.sh'
# source "$REPLY"

unbootstrap
