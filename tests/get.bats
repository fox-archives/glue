#!/usr/bin/env bats

source ./lib/util/get.sh

@test "get.task" {
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

		get.task "$input"
		result="$REPLY"

		# {
		# 	echo ---
		# 	echo "$input"
		# 	echo "$result"
		# 	echo "$expected"
		# } >&3

		[[ $result == "$expected" ]]
	done
}

@test "get.projectType" {
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

		get.projectType "$input"
		result="$REPLY"

		# {
		# 	echo ---
		# 	echo "$input"
		# 	echo "$result"
		# 	echo "$expected"
		# } >&3

		[[ $result == "$expected" ]]
	done
}

@test "get.when" {
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

		get.when "$input"
		result="$REPLY"

		# {
		# 	echo ---
		# 	echo "$input"
		# 	echo "$result"
		# 	echo "$expected"
		# } >&3

		[[ $result == "$expected" ]]
	done
}
