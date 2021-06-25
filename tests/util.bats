#!/usr/bin/env bats

source ./lib/util/util.sh

setup_file() {
	unset GLUE_CONFIG_USER
	unset GLUE_CONFIG_LOCAL
}

@test util.get_config_string {
	GLUE_CONFIG_USER="$PWD/../tests/mocks/glueUser.toml"
	GLUE_CONFIG_LOCAL="$PWD/../tests/mocks/glueLocal.toml"

	util.get_config_string 'key1'
	[ "$REPLY" = 'mar' ]

	util.get_config_string 'key2'
	[ "$REPLY" = 'bar' ]

	util.get_config_string 'key3'
	[ "$REPLY" = 'far' ]
}
