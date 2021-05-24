# reference.md

## Variables

Available variables after calling `args.parse`. If the values of the variables appear to be blank, you may have to declare the variable before calling `args.parse`

### `argsPostHyphen`

An array that contains every argument or flag after the first `--`

```sh
declare -a argsPostHyphen=()

args.parse --port 3005 -- ls -L --color=always /lib <<-'EOF'
	@flag [port] {3000} - The port to open on
EOF

echo "${argsPostHyphen[*]}"
# ls -L --color=always /lib
```

### `argsRawSpec`

A string that is a copy of standard input to `args.parse`

```sh
declare argsRawSpec=

args.parse --port 3005 <<-'EOF'
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

args.parse --port 3005 <<-'EOF'
	@flag [port.p] {3000} - The port to open on
EOF

echo "${args[port]} ${args[p]}"
# 3005 3005

args.parse -p 3005 <<-'EOF'
	@flag [port.p] {3000} - The port to open on
EOF

echo "${args[port]} ${args[p]}"
# 3005 3005
```
