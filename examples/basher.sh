#!/usr/bin/env bash

# https://github.com/basherpm/basher

source args.parse <<"EOF"
@arg help - Display help for a command
@arg commands - List all available basher commands
@arg init - Configure the shell environment for basher
EOF
