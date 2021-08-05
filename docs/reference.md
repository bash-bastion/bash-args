# API Reference

## Variables

Available variables after calling `bash-args`. If the values of the variables appear to be blank, you may have to declare the variable before calling `bash-args`

### `argsPostHyphen`

An array that contains every argument or flag after the first `--`

```sh
declare -a argsPostHyphen=()

source bash-args parse --port 3005 -- ls -L --color=always /lib <<-'EOF'
	@flag [port] {3000} - The port to open on
EOF

echo "${argsPostHyphen[*]}"
# ls -L --color=always /lib
```

### `argsRawSpec`

A string that is a copy of standard input to `bash-args`

```sh
declare argsRawSpec=

source bash-args parse --port 3005 <<-'EOF'
	@flag [port] {3000} - The port to open on
	@flag [version.v] - Prints program version
EOF

echo "$argsRawSpec"
# @flag [port] {3000} - The port to open on
# @flag [version.v] - Prints program version
```

### `args`

An associative array that contains the values of arguments

```sh
declare -A args=()

source bash-args parse --port 3005 <<-'EOF'
	@flag [port.p] {3000} - The port to open on
EOF

echo "${args[port]} ${args[p]}"
# 3005 3005

source bash-args parse -p 3005 <<-'EOF'
	@flag [port.p] {3000} - The port to open on
EOF

echo "${args[port]} ${args[p]}"
# 3005 3005
```

### `argsCommands`

An array contaning all the commands supplied

```sh
declare -a argsCommands=()

source bash-args parse --port 3005 serve --user admin now --enable-security <<-'EOF'
	@flag [port.p] {3000} - The port to open on
EOF

echo "${argsCommands[*]}"
# serve now
```

### `argsHelpText`

The full generated help text

```sh
source bash-args parse parse "$@" <<-"EOF"
@flag [port.p] {3000} - The port to open on
EOF

echo "$argsHelpText"
# Usage:
#   stdin [flags] <arguments>

# Flags:
#   p, port           (Default: 3000)
```
