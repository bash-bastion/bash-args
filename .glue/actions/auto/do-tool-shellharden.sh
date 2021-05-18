#!/usr/bin/env bash
eval "$GLUE_ACTIONS_BOOTSTRAP_DID"
bootstrap || exit

ensure.cmd 'shellharden'

util.shopt -s nullglob
util.shopt -s dotglob

# shellharden --suggest -- **/*.{sh,bash}
# shellharden --check -- **/*.{sh,bash}

unbootstrap
