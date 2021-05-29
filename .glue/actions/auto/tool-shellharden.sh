#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

ensure.cmd 'shellharden'

util.shopt -s globstar
util.shopt -s nullglob

# shellharden --suggest -- ./**/*.{sh,bash}
# shellharden --check -- ./**/*.{sh,bash}

unbootstrap
