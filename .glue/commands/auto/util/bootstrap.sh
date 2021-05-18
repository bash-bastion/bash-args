# shellcheck shell=bash

bootstrap() {
	if [ -f "$GLUE_WD/.glue/common/util/bootstrap.sh" ]; then
		source "$GLUE_WD/.glue/common/util/bootstrap.sh"

	elif [ -f "$GLUE_WD/.glue/common/auto/util/bootstrap.sh" ]; then
		source "$GLUE_WD/.glue/common/auto/util/bootstrap.sh"
	else
		echo "Context \$0: '$0'" >&2
		echo "Context \${BASH_SOURCE[*]}: ${BASH_SOURCE[*]}" >&2
		echo "Error: bootstrap: Tertiary stage bootstrap file not found. Exiting" >&2
		exit 1
	fi

	bootstrap.init
	bootstrap.abstract 'commands'
	command.log
}

unbootstrap() {
	bootstrap.deinit
}
