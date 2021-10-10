#!/usr/bin/env bats

load './util/init.sh'

@test "argsCommands is correct basic" {
	declare -A args
	declare -a argsCommands=()

	bash-args parse alfa bravo <<-'EOF'
	@flag [port.p] {3000} - The port to open on
	EOF

	[[ "${#argsCommands[@]}" = 2 ]]
	[[ "${argsCommands[0]}" = alfa ]]
	[[ "${argsCommands[1]}" = bravo ]]
}


@test "argsCommands is correct advanced" {
	declare -A args
	declare -a argsCommands=()

	bash-args parse --port 3005 serve --user admin --enable-security now <<-'EOF'
	@flag [port.p] {3000} - The port to open on
	@flag [user] {} - User
	@flag [enable-security] - Enable security
	EOF

	[[ "${#argsCommands[@]}" = 2 ]]
	[[ "${argsCommands[0]}" = serve ]]
	[[ "${argsCommands[1]}" = now ]]
}

@test "argsCommands works with boolean flags" {
	declare -A args
	declare -a argsCommands=()

	bash-args parse --port 3005 serve now --enable-security last <<-'EOF'
	@flag [port.p] {3000} - The port to open on
	@flag [enable-security] - Whether to enable security
	EOF

	[[ "${#argsCommands[@]}" = 3 ]]
	[[ "${argsCommands[0]}" = serve ]]
	[[ "${argsCommands[1]}" = now ]]
	[[ "${argsCommands[2]}" = last ]]
}
