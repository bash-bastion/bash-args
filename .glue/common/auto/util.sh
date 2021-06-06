# shellcheck shell=bash

# Get the absolute path of the absolute working directory of
# the current project. Do not specify function with '()' because
# we assume consumer invokes function in subshell to capture output
util.get_working_dir() {
	while [ ! -f "glue.sh" ] && [ "$PWD" != / ]; do
		cd ..
	done

	if [ "$PWD" = / ]; then
		die 'No glue config file found in current or parent paths'
	fi

	printf "%s\n" "$PWD"
}

# Get any particular file, parameterized by any
# top level folder contained within "$GLUE_WD/.glue"
util.get_file() {
	local dir="$1"
	local file="$2"

	ensure.nonZero 'dir' "$dir"
	ensure.nonZero 'file' "$file"

	REPLY=
	if [ -f "$GLUE_WD/.glue/$dir/$file" ]; then
		REPLY="$GLUE_WD/.glue/$dir/$file"
	elif [ -f "$GLUE_WD/.glue/$dir/auto/$file" ]; then
		REPLY="$GLUE_WD/.glue/$dir/auto/$file"
	else
		error.file_not_found_in_dot_glue_dir "$file" "$dir"
	fi
}

# Get any particular file in the 'actions' directory
# Pass '-q' as the first arg to set the result to
# '$REPLY' rather than outputing to standard output
util.get_action() {
	if [ "$1" = "-p" ]; then
		util.get_file "actions" "$2"
		printf "%s\n" "$REPLY"
	else
		util.get_file "actions" "$1"
	fi
}

# Get any particular file in the 'commands' directory
# Pass '-q' as the first arg to set the result to
# '$REPLY' rather than outputing to standard output
util.get_command() {
	if [ "$1" = "-p" ]; then
		util.get_file "commands" "$2"
		printf "%s\n" "$REPLY"
	else
		util.get_file "commands" "$1"
	fi
}

# Get any particular file in the 'configs' directory
# Pass '-q' as the first arg to set the result to
# '$REPLY' rather than outputing to standard output
util.get_config() {
	if [ "$1" = "-p" ]; then
		util.get_file "configs" "$2"
		printf "%s\n" "$REPLY"
	else
		util.get_file "configs" "$1"
	fi
}

util.ln_config() {
	ensure.args 'util.ln_config' '1 2' "$@"

	if [ -f "$GLUE_WD/.glue/configs/$1" ]; then
		ln -sfT ".glue/configs/$1" "${2:-"$GLUE_WD/$1"}"
	elif [ -f "$GLUE_WD/.glue/configs/auto/$1" ]; then
		ln -sfT ".glue/configs/auto/$1" "${2:-"$GLUE_WD/$1"}"
	else
		error.file_not_found_in_dot_glue_dir "$1" 'configs'
	fi
}

# Set or unset a shopt parameter, which will be reversed
# during the bootstrap.deinit phase
util.shopt() {
	ensure.args 'util.shopt' '1 2' "$@"

	shopt "$1" "$2"
	_util_shopt_data+="$1.$2 "
}

util.prompt_new_version() {
	local currentVersion="$1"

	ensure.nonZero 'currentVersion' "$currentVersion"

	# TODO: make incremenet better
	REPLY=
	echo "Current Version: $currentVersion"
	read -rp 'New Version? ' -ei "$currentVersion"
}

util.git_generate_version() {
	REPLY=

	# If the working tree is dirty and there are unstaged changes
	# for both tracked and untracked files
	local dirty=
	if is.git_working_tree_dirty; then
		dirty=yes
	fi

	# Get the most recent Git tag that specifies a version
	local version
	if version="$(git describe --match 'v*' --abbrev=0 2>/dev/null)"; then
		version="${version/#v/}"
	else
		version="0.0.0"
	fi

	local id
	id="$(git rev-parse --short HEAD)"
	version+="+$id${dirty:+-DIRTY}"
	REPLY="$version"
}

util.general_version_bump() {
	local newVersion="$1"

	sed -i -e "s|\(version[ \t]*=[ \t]*\"\).*\(\"\)|\1${newVersion}\2|g" glue-auto.toml
}
