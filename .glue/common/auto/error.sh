# shellcheck shell=bash

# If a file was not found in the glue store, print an
# error, showing the directories searched, and any
# useful tips (beacuset this error will be bound to crop up)
error.file_not_found_in_dot_glue_dir() {
	log.error "Could not find '$1' in '.glue/$2' or '.glue/auto/$2'"
	echo "    -> Did you spell the filename or dirname correctly when using annotations like 'useAction(...)'?"
	echo "    -> Did you spell the filename or dirname correctly when using functions like 'util.get_config' or 'util.ln_config'?"
	exit 1
}

error.cd_failed() {
	die "Some 'cd' failed"
}

error.not_supported() {
	die "Argument '$*' not supported"
}

error.empty() {
	die "Argument '$1' is empty"
}
