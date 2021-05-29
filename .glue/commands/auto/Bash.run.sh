#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

dirty=
if [ -n "$(git status --porcelain)" ]; then
	dirty=yes
fi

if version="$(git describe --match 'v*' --abbrev=0 2>/dev/null)"; then
	version="${version/#v/}"
else
	version="0.0.0"
fi

id="$(git rev-parse --short HEAD)"
version+="+$id${dirty:+-DIRTY}"

sed -i -e "s|\(version=\"\).*\(\"\)|\1${version}\2|g" glue.toml

# TODO: exec project

# if [ -f Taskfile.yml ]; then
# 	if command -v go-task &>/dev/null; then
# 		go-task run "$@"
# 	elif command -v task &>/dev/null; then
# 		if ! task help | grep -q Taskwarrior; then
# 			task run "$@"
# 		else
# 			ensure.cmd 'go-task'
# 		fi
# 	else
# 		ensure.cmd 'go-task'
# 	fi
# elif [ -f Justfile ]; then
# 	ensure.cmd 'just'

# 	just run "$@"
# fi

unbootstrap
