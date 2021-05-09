#!/usr/bin/env bats

source ../lib/util.sh

@test "contains_element" {
	declare -a array1=(one two three)
	run contains_element one "${array1[@]}"
	((status == 0))

	declare -a array2=(one two three)
	run contains_element four "${array2[@]}"
	((status == 1))
}
