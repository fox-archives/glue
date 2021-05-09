#!/usr/bin/env bats

# load ./test_utils
source ../lib/helper.sh
source ../lib/util.sh

@test "util_get_subcommand" {
	local input result expected
	local -A tests=(
		# subcommand alone
		[build]=build

		# subcommand and lang
		[build-go]=build

		# subcommand and when
		[build-before]=build

		# subcommand and lang and when
		[build-go-after]=build
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
		# subcommand alone
		[build]=

		# subcommand and lang
		[build-go]=go

		# subcommand and when
		[build-before]=

		# subcommand and lang and when
		[build-go-after]=go
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

@test "util_get_when" {
	local input result expected
	local -A tests=(
		# subcommand alone
		[build]=

		# subcommand and lang
		[build-go]=

		# subcommand and when
		[build-before]=before

		# subcommand and lang and when
		[build-go-after]=after
	)

	for i in "${!tests[@]}"; do
		input="$i"
		expected="${tests[$i]}"
		result="$(util_get_when "$input")"

		# {
		# 	echo ---
		# 	echo "$input"
		# 	echo "$result"
		# 	echo "$expected"
		# } >&3

		[[ $result == "$expected" ]]
	done
}

@test "util_sort_files_by_when" {

	# 1
	local -a input=('build-before.sh' 'build.sh')
	local -a expected=('build-before.sh' 'build.sh')
	local -a result
	readarray -d $'\0' result < <(util_sort_files_by_when "${input[@]}")

	# ensure equivalency
	[[ ${#expected[@]} == "${#result[@]}" ]]
	for i in "${!result[@]}"; do
		[[ ${expected[$i]} == "${result[$i]}" ]]
	done


	# 2
	local -a input=('build-go-after.sh' 'build-go-before.sh' 'build-go.sh')
	local -a expected=('build-go-before.sh' 'build-go.sh' 'build-go-after.sh')
	local -a result
	readarray -d $'\0' result < <(util_sort_files_by_when "${input[@]}")

	# ensure equivalency
	[[ ${#expected[@]} == "${#result[@]}" ]]
	for i in "${!result[@]}"; do
		[[ ${expected[$i]} == "${result[$i]}" ]]
	done
}

@test "util_get_command_and_lang_scripts" {
	local dir

	dir="$PWD/mocks/util-source-commands"

	# 1
	local -a result
	readarray -d $'\0' result < <(util_get_command_and_lang_scripts "build" "go" "$dir")

	# echo "${result[@]}" >&3
}
