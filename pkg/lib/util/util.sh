# shellcheck shell=bash
# @file util.sh
# @brief Utility functions
# @description Contains utility functions for the library


# @description Prints 'Could not source file' error and exits
#
# @example
#   source ./non-existent-file || util.source_error
#
# @exitcode 1 Exits with `1`
util.source_error() {
	echo "Error: Could not source file"
	exit 1
}

# @description Prints the help menu
util.show_help() {
	cat <<-EOF
	glue [flags] <command>

	Commands:
	    sync
	        Sync changes from the Glue store to the current project.
	        This overrides and replaces the content in 'auto' directories

	    list
	        Lists all projectTypes of the current project

	    print
	        Prints the script about to be executed

	    act <actionFile>
	        Execute an action

	    cmd <metaTask>
	        Execute a meta task (command)

	Flags:
	    --help
	        Show help menu

	    --version
	        Show current version
	EOF
}

# @description Prints the current version
util.show_version() {
	cat <<-EOF
	Version: $PROGRAM_VERSION
	EOF
}

# TODO: fix?
# @description From stdin, pick the key of a TOML entry
util.get_toml_key() {
	local keyName="$1"

	grep "$keyName" | sed "s|$keyName[ \t]*=[ \t]*[\"']\(.*\)[\"']|\1|g"
}

# @description Reads a string from the config files. It substitutes common environment variables for their actual value
util.get_config_string() {
	REPLY=
	local keyName="$1"
	local keyValue

	local glueConfigUser="${GLUE_CONFIG_USER:-${XDG_CONFIG_HOME:-$HOME/.config}/glue/glue.toml}"
	local glueConfigLocal="${GLUE_CONFIG_LOCAL:-"$GLUE_WD/glue.toml"}"

	for cfgFile in "$glueConfigUser" "$glueConfigLocal"; do
		local grepLine=
		while IFS= read -r line; do
			if [[ $line == *"$keyName"*=* ]]; then
				grepLine="$line"
				break
			fi
		done < "$cfgFile"

		# If the grepLine is empty, it means the key wasn't found, and we continue to
		# the next configuration file. We need the intermediary grep check because
		# we don't want to set the value to an empty string if it the config key is
		# not found in the file (since piping to sed would result in something indistinguishable
		# from setting the key to an empty string value)
		if [ -z "$grepLine" ]; then
			continue
		fi

		# TODO: bash rematch
		keyValue="$(<<< "$grepLine" sed "s|$keyName[ \t]*=[ \t]*[\"']\(.*\)[\"']|\1|g")"
	done

	# Transitively sets 'REPLY'
	util.substitute_variables "$keyValue"
}

# @description Reads an array from the config files.
util.get_config_array() {
REPLY=
	local keyName="$1"
	local keyValue

	local glueConfigUser="${GLUE_CONFIG_USER:-${XDG_CONFIG_HOME:-$HOME/.config}/glue/glue.toml}"
	local glueConfigLocal="${GLUE_CONFIG_LOCAL:-glue.toml}"

	for cfgFile in "$glueConfigUser" "$glueConfigLocal"; do
		local grepLine=
		while IFS= read -r line; do
			if [[ $line == *"$keyName"*=* ]]; then
				grepLine="$line"
				break
			fi
		done < "$cfgFile"

		# If the grepLine is empty, it means the key wasn't found, and we continue to
		# the next configuration file. We need the intermediary grep check because
		# we don't want to set the value to an empty string if it the config key is
		# not found in the file (since piping to sed would result in something indistinguishable
		# from setting the key to an empty string value)
		if [ -z "$grepLine" ]; then
			continue
		fi

		local -a usingArray
		local regex="[ \t]*${keyName}[ \t]*=[ \t]*\[[ \t]*(.*)[ \t]*\]"
		if [[ "$grepLine" =~ $regex ]]; then
			local arrayString="${BASH_REMATCH[1]}"

			IFS=',' read -ra usingArray <<< "$arrayString"
			for i in "${!usingArray[@]}"; do
				# Treat all TOML strings the same; there shouldn't be
				# any escape characters anyways
				local regex="[ \t]*['\"](.*)['\"]"
				if [[ ${usingArray[$i]} =~ $regex ]]; then
					usingArray[$i]="${BASH_REMATCH[1]}"
				else
					die "Array for key '$keyName' not valid"
				fi
			done
		else
			die "Key '$keyName' in file '$cfgFile' must be set to an array that spans one line"
		fi

	done

	# shellcheck disable=SC2034
	REPLIES=("${usingArray[@]}")
}

# Substitutes
util.substitute_variables() {
	local string="$1"

	string="${string/#~/"$HOME"}"
	string="${string/\$HOME/"$HOME"}"
	string="${string/\$XDG_CONFIG_HOME/"${XDG_CONFIG_HOME:-"$HOME/.config"}"}"
	string="${string/\$XDG_DATA_HOME/"${XDG_DATA_HOME:-"$HOME/.local/share"}"}"

	REPLY="$string"
}
