#!/usr/bin/env bash

# https://github.com/dominictarr/JSON.sh

source ./bin/args-init

args.parse -- <<"EOF"
@flag [.p] - Prune empty. Exclude fields with empty values.
@flag [.l] - Leaf only. Only show leaf nodes, which stops data duplication.
@flag [.b] - Brief. Combines 'Leaf only' and 'Prune empty' options.
@flag [.n] - No-head. Do not show nodes that have no path (lines that start with []).
@flag [.s] - Remove escaping of the solidus symbol (straight slash).
@flag [.h] - This help text.
EOF

printf "%s" "$argsHelpText"
