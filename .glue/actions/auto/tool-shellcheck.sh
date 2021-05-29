#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

ensure.cmd 'shellcheck'

# https://github.com/koalaman/shellcheck/issues/143
# find . -ignore_readdir_race -regex '.*\.\(sh\|ksh\|bash\)' -print0 \
# 	| xargs -r0 \
# 	shellcheck --check-sourced --


util.shopt -u dotglob
util.shopt -s globstar
util.shopt -s nullglob

shellcheck --check-sourced -- ./**/*.{sh,ksh,bash}

unbootstrap
