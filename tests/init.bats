#!/usr/bin/env bats

load 'util/init.sh'

@test "creates basic files" {
	[ ! -f glue.toml ]
	[ ! -f glue-auto.toml ]

	glue init

	[ -f glue.toml ]
	[ -f glue-auto.toml ]
}
