# shellcheck shell=bash

is.git_working_tree_dirty() {
	[ -n "$(git status --porcelain)" ]
}

# must be set to 'wet' to not be dry, which so
# that it defaults to 'dry' on empty
is.dry_release() {
	[ "$RELEASE_STATUS" != 'wet' ]
}
