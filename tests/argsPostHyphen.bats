#!/usr/bin/env bash

load './util/init.sh'

@test "append to post argsPostHyphen if set" {
	declare -A args=()
	declare -a argsPostHyphen=()

	bash-args parse "--port" "3005" -- one two <<-'EOF'
	@flag [port] {3000} - The port to open on
	EOF

	[[ "${#argsPostHyphen[@]}" = 2 ]]
	[[ "${argsPostHyphen[0]}" = one ]]
	[[ "${argsPostHyphen[1]}" = two ]]
}
