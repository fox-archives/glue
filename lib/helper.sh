# shellcheck shell=bash

util_get_gluefile() {
	printf "%s" "./glue.sh"
}

util_source_config() {
	ensure_fn_args 'util_source_config' '1' "$@"

	glueFile="$1"

	ensure_file_exists "$glueFile"
	set -a
	# shellcheck disable=SC1090
	. "$glueFile"
	set +a
}

util_get_subcommand() {
	ensure_fn_args 'util_get_subcommand' '1' "$@"

	local subcommand
	subcommand="${1%%-*}"

	printf "%s" "$subcommand"
}

util_get_lang() {
	ensure_fn_args 'util_get_variation' '1' "$@"

	local variation
	variation="${1#*-}"

	if [ "$1" = "$variation" ]; then
		printf ''
	else
		printf "%s" "$variation"
	fi
}

# run each command that is language-specific. then
# run the generic version of a particular command. for each one,
# only run the-user command file is one in 'auto' isn't present
# util_get_command_scripts() {
# 	ensure_fn_args 'util_source_command' '1' "$@"

# 	# source files specific to language
# 	local -a autoCommandsRan
# 	for file in ./glue/commands/auto/"$1"-*.sh; do
# 		:
# 	done

# 	for file in ./glue/commands/"$1"-*.sh; do
# 		:
# 	done

# 	# source generic files
# 	local -a files=(
# 		".glue/commands/auto/$1.sh"
# 		".glue/commands/$1.sh"
# 	)

# 	for file in "${files[@]}"; do
# 		if [ -f "$file" ]; then
# 			if [ -x "$file" ]; then
# 				"./$file"
# 				return
# 			else
# 				log_warn "File '$file' exists, but is not executable. Skipping"
# 			fi
# 		fi
# 	done

# 	die "Could not find file executable for command '$1'"
# }

# only run a language specific version of a command
util_get_command_and_lang_scripts() {
	ensure_fn_args 'util_source_command_variation' '1 2 3' "$@"

	local subcommand="$1"
	local lang="$2"
	local dir="$3"

	
}
