# bash-args

A cute little Bash library for blazing fast argument parsing

STATUS: IN DEVELOPMENT!

## Summary

- Uses only builtins
- Uses no subshells
- Simple API

## Usage

```sh
barg.define_flags \
	one \
		'--alfa' '-a' '|bool|' 'desc' \
		'--bravo' '' 'i' 'desc' \
		'' '-charlie' 'i' 'desc' \
		END \
	subcommand \
		END

barg.parse_flags "$@"
```

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to add this project as a dependency

```sh
basalt add hyperupcall/bash-args
```
