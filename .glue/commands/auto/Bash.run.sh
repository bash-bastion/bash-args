#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

declare cmdName="$1"
ensure.nonZero 'cmdName' "$cmdName"
shift

if [ -d pkg ]; then
	cd pkg || error.cd_failed
fi

declare execPath="$PWD/bin/$cmdName"
if [ -f "$execPath" ]; then
	if [ -x "$execPath" ]; then
		"$execPath" "$@"
	else
		error.not_executable "$execPath"
	fi
else
	echo "Executable file '$execPath' not found"
fi


unbootstrap
