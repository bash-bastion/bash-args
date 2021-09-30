# bash-args

A cute little Bash library for blazing fast argument parsing

## Summary

- Uses only builtins
- Uses no subshells
- Simple API

TODO: add types of options to table

| Software | No Codegen | No getopts/getopt | Preserves arguments | At least some testing
| - | - | - | - | - |
| hyperupcall/bash-args | Yes | Yes | Yes | Yes
| [argbash]       | No | No | ?
| [bash-argsparse] | No | No | ?
| [easyoptions] | No | No | ?
| [longoption] | Yes | ? | ?
| [bash_option_parser] | Yes | Yes | Yes | No
| [opts.bash] | Yes | No | No | Yes

[argbash]: https://github.com/matejak/argbash
[bash-argsparse]: https://github.com/Anvil/bash-argsparse
[easyoptions]: https://github.com/renatosilva/easyoptions
[longoption]: https://github.com/team-lab/longoption
[bash_option_parser]: https://github.com/MihirLuthra/bash_option_parser
[opts.bash]: https://github.com/reconquest/opts.bash

## Installation

STATUS: IN DEVELOPMENT!

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to add this project as a dependency


```sh
basalt add hyperupcall/bash-args
```

## Usage

```bash
# Declaring `args` may be required
declare -A args=()

# Pass through your command line arguments to 'args'
# Pass your argument specification through stdin (see more examples below)
bash-args parse "$@" <<-"EOF"
@flag [port.p] {3000} - The port to open on
EOF

# Use either the long or short flags to get value
echo "Using port '${args[port]}'"

# 'argsCommands' contains all commands (arguments that are not
# either flags or values for flags)
echo "argsCommands: ${argsCommands[*]}"

# 'argsPostHyphen' contains everything after the first '--'
echo "argsPostHyphen: ${argsPostHyphen[*]}"

# Print the help text
echo "argsHelpText: $argsHelpText"
```

### Argument Specification

The following are valid lines and their explanations to pass as stdin to `bash-args`

#### `@flag [verbose] - Enable verbose logging`

`verbose` is a boolean flag. Any argument succeeding it will not be interpreted as a value to the flag. In the `args` associative array, the value is `yes` if the flag is supplied, and `no` if otherwise

#### `@flag [port] {} - Port to open on`

`port` is _not_ a boolean flag. You must specify a value if you decide to pass it to the command line. By default, it will be empty

#### `@flag [port] {3000} - Port to open on`

Same as previous, but the default value is `3000`

#### `@flag [port.p] {3000} - Port to open on`

Same as previous, but you can also specify the value with `-p`. Note that both `port` _and_ `p` properties will be properly populated in the `args` associative array

#### `@flag [.p] {3000} - Port to open on`

Same as previous before previous, but only specify the short argument

#### `@flag <port.p> - Port to open on`

Specify a non-boolean flag, `port`, and require that it's value _must_ be specified with either `-p` or `--port`. Of course, you can use the sideways carrot notation with other variants

#### `@arg build - Build project`

Specify a valid argument, or command called 'build' with a description
