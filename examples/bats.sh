#!/usr/bin/env bash

# https://github.com/bats-core/bats-core

source args.parse -- <<"EOF"
@flag [count.c] - Count test cases without running any tests
@flag [filter.f] {} - Only run tests that match the regular expression
@flag [formatter.F] {pretty} - Swithc between formatters: pretty (default), tap (default w/o term), tap13, junit
@flag [help.h] - Display this help message
@flag [jobs.j] {1} - Number of parallel jobs (requires GNU parallel)
@flag [no-tempdir-cleanup] - Serialize test file execution instead of running them in parallel (requires --jobs >1)
@flag [no-parallelize-within-files] - Serialize test execution within files instead of running them in parallel (requires --jobs >1)
@flag [output.o] {} - Directory to write report files
@flag [pretty.p] - Shorthand for "--formatter pretty"
@flag [recursive.r] - Include tests in subdirectories
@flag [tap.t] - Shorthand for "--formatter tap"
@flag [timing.T] - Add timing information to tests
@flag [version.v] - Display the version number
EOF

printf "%s" "$argsHelpText"
