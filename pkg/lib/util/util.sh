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

# @description Retrieve a string key from a toml file
util.get_toml_string() {
	REPLY=
	local tomlFile="$1"
	local keyName="$2"

	ensure.file "$tomlFile"

	local grepLine=
	while IFS= read -r line; do
		if [[ $line == *"$keyName"*=* ]]; then
			grepLine="$line"
			break
		fi
	done < "$tomlFile"

	# If the grepLine is empty, it means the key wasn't found, and we continue to
	# the next configuration file. We need the intermediary grep check because
	# we don't want to set the value to an empty string if it the config key is
	# not found in the file (since piping to sed would result in something indistinguishable
	# from setting the key to an empty string value)
	if [ -z "$grepLine" ]; then
		REPLY=''
		return 1
	fi

	local regex="[ \t]*${keyName}[ \t]*=[ \t]*['\"](.*)['\"]"
	if [[ $grepLine =~ $regex ]]; then
		REPLY="${BASH_REMATCH[1]}"
	else
		die "Value for key '$keyName' not valid"
	fi
}

# @description Retrieve an array key from a TOML file
util.get_toml_array() {
	declare -ga REPLIES=()
	local tomlFile="$1"
	local keyName="$2"

	local grepLine=
	while IFS= read -r line; do
		if [[ $line == *"$keyName"*=* ]]; then
			grepLine="$line"
			break
		fi
	done < "$tomlFile"

	# If the grepLine is empty, it means the key wasn't found, and we continue to
	# the next configuration file. We need the intermediary grep check because
	# we don't want to set the value to an empty string if it the config key is
	# not found in the file (since piping to sed would result in something indistinguishable
	# from setting the key to an empty string value)
	if [ -z "$grepLine" ]; then
		REPLY=''
		return 1
	fi

	local regex="[ \t]*${keyName}[ \t]*=[ \t]*\[[ \t]*(.*)[ \t]*\]"
	if [[ "$grepLine" =~ $regex ]]; then
		local -r arrayString="${BASH_REMATCH[1]}"

		IFS=',' read -ra REPLIES <<< "$arrayString"
		for i in "${!REPLIES[@]}"; do
			# Treat all TOML strings the same; there shouldn't be
			# any escape characters anyways
			local regex="[ \t]*['\"](.*)['\"]"
			if [[ ${REPLIES[$i]} =~ $regex ]]; then
				REPLIES[$i]="${BASH_REMATCH[1]}"
			else
				die "Array for key '$keyName' not valid"
			fi
		done
	else
		die "Key '$keyName' in file '$cfgFile' must be set to an array that spans one line"
	fi
}


# @description Reads a string from the config files. It substitutes common environment variables for their actual value
util.get_config_string() {
	REPLY=
	local keyName="$1"

	local value

	local glueConfigUser="${GLUE_CONFIG_USER:-${XDG_CONFIG_HOME:-$HOME/.config}/glue/glue.toml}"
	local glueConfigLocal="${GLUE_CONFIG_LOCAL:-"$GLUE_WD/glue.toml"}"

	local cfgFile
	for cfgFile in "$glueConfigUser" "$glueConfigLocal"; do
		if util.get_toml_string "$cfgFile" "$keyName"; then
			value="$REPLY"
		fi
	done

	# Transitively sets 'REPLY'
	util.substitute_variables "$value"
}

# @description Reads an array from the config files.
util.get_config_array() {
	declare -ga REPLIES=()
	local keyName="$1"

	local -a value

	local glueConfigUser="${GLUE_CONFIG_USER:-${XDG_CONFIG_HOME:-$HOME/.config}/glue/glue.toml}"
	local glueConfigLocal="${GLUE_CONFIG_LOCAL:-glue.toml}"

	local cfgFile
	for cfgFile in "$glueConfigUser" "$glueConfigLocal"; do
		if util.get_toml_array "$cfgFile" "$keyName"; then
			IFS=' ' read -ra value <<< "${REPLIES[@]}"
		fi
	done

	IFS=' ' read -ra REPLIES <<< "${value[@]}"
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
