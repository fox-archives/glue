#!/usr/bin/env bats

# load ./test_utils
source ../lib/helper.sh
source ../lib/util.sh

@test "helper_get_task" {
	local input result expected
	local -A tests=(
		# task and projectName
		[Go.build]=build

		# task and lang and when
		[Go.build-after]=build

		# task alone
		[build]=build

		# task and when
		[build-before]=build
	)

	for i in "${!tests[@]}"; do
		input="$i"
		expected="${tests[$i]}"
		result="$(helper_get_task "$input")"

		# {
		# 	echo ---
		# 	echo "$input"
		# 	echo "$result"
		# 	echo "$expected"
		# } >&3

		[[ $result == "$expected" ]]
	done
}

@test "helper_get_projectType" {
	local input result expected
	local -A tests=(
		# task and projectName
		[Go.build]=Go

		# task and lang and when
		[Go.build-after]=Go

		# task alone
		[build]=

		# task and when
		[build-before]=
	)

	for i in "${!tests[@]}"; do
		input="$i"
		expected="${tests[$i]}"
		result="$(helper_get_projectType "$input")"

		# {
		# 	echo ---
		# 	echo "$input"
		# 	echo "$result"
		# 	echo "$expected"
		# } >&3

		[[ $result == "$expected" ]]
	done
}

@test "helper_get_when" {
	local input result expected
	local -A tests=(
		# task and projectName
		[Go.build]=

		# task and lang and when
		[Go.build-after]=after

		# task alone
		[build]=

		# task and when
		[build-before]=before
	)

	for i in "${!tests[@]}"; do
		input="$i"
		expected="${tests[$i]}"
		result="$(helper_get_when "$input")"

		# {
		# 	echo ---
		# 	echo "$input"
		# 	echo "$result"
		# 	echo "$expected"
		# } >&3

		[[ $result == "$expected" ]]
	done
}
