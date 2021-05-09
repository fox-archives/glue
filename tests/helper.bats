#!/usr/bin/env bats

load ./test_utils
source ../lib/helper.sh
source ../lib/util.sh

@test "util_get_subcommand" {
	local input result expected
	local -A tests=(
		[build]=build
		[build-go]=build
	)

	for i in "${!tests[@]}"; do
		input="$i"
		expected="${tests[$i]}"
		result="$(util_get_subcommand "$input")"

		# {
		# 	echo ---
		# 	echo "$input"
		# 	echo "$result"
		# 	echo "$expected"
		# } >&3

		[[ $result == "$expected" ]]
	done
}

@test "util_get_lang" {
	local input result expected
	local -A tests=(
		[build]=
		[build-go]=go
	)

	for i in "${!tests[@]}"; do
		input="$i"
		expected="${tests[$i]}"
		result="$(util_get_lang "$input")"

		# {
		# 	echo ---
		# 	echo "$input"
		# 	echo "$result"
		# 	echo "$expected"
		# } >&3

		[[ $result == "$expected" ]]
	done
}

@test "util_get_command_and_lang_scripts" {
	local subcommand lang dir

	subcommand="build"
	lang="go"
	dir="./mocks/util-source-commands"

	# 1
	result="$(util_get_command_and_lang_scripts "$subcommand" "$lang" "$dir")"
}
