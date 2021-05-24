# shellcheck shell=bash

bootstrap.init() {
	set -Eo pipefail

	trap 'bootstrap.init.int' INT
	bootstrap.init.int() {
		die 'Received SIGINT'
	}

	_original_wd="$PWD"
	trap 'bootstrap.init.exit' EXIT
	bootstrap.init.exit() {
		# shellcheck disable=SC2164
		cd "$_original_wd"
	}
}

bootstrap.deinit() {
	for option in $_util_shopt_data; do
		optionValue="${option%.*}"
		optionName="${option#*.}"

		local newOptionValue
		case "$optionValue" in
			-s) newOptionValue="-u" ;;
			-u) newOptionValue="-s" ;;
		esac

		shopt "$newOptionValue" "$optionName"
	done

	_util_shopt_data=
}

bootstrap.abstract() {
	local dirArg="$1"

	if [ -z "$dirArg" ]; then
		echo "Error: bootstrap.abstract: Must supply an argument 'dir'" >&2
		exit 1
	fi

	for dir in common "$dirArg"; do
		shopt -q nullglob
		local shoptExitStatus="$?"
		shopt -s nullglob

		local -a filesToSource=()

		# Add file in 'util' to filesToSource,
		# ensuring priority of 'override' scripts
		local file possibleFileBasename
		for file in "$GLUE_WD/.glue/$dir/util"/*?.sh; do
			filesToSource+=("$file")
		done

		# Add an 'auto' file if it doesn not have a name of 'bootstrap.sh',
		# or if the name does not already exist in the filesToSource array
		for possibleFile in "$GLUE_WD/.glue/$dir/auto/util"/*?.sh; do
			possibleFileBasename="${possibleFile##*/}"

			if [[ $possibleFileBasename == 'bootstrap.sh' ]]; then
				continue
			fi

			# loop over exiting files that we're going to source
			# and ensure 'possibleFile' is not already there
			local alreadyThere=no
			for file in "${filesToSource[@]}"; do
				fileBasename="${file##*/}"

				# if the file is not included (which means it's not
				# already covered by 'override'), add it
				if [[ $fileBasename == "$possibleFileBasename" ]]; then
					alreadyThere=yes
				fi
			done

			if [[ $alreadyThere == no ]]; then
				filesToSource+=("$possibleFile")
			fi
		done

		(( shoptExitStatus != 0 )) && shopt -u nullglob

		for file in "${filesToSource[@]}"; do
			source "$file"
		done
	done
}
