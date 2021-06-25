#!/usr/bin/env bats

source ./lib/util/util.sh

setup_file() {
	unset GLUE_CONFIG_USER
	unset GLUE_CONFIG_LOCAL
}

@test util.get_config_key {
	GLUE_CONFIG_USER="$PWD/../tests/glueUser.toml"
	GLUE_CONFIG_LOCAL="$PWD/../tests/glueLocal.toml"

	toml.get_config_key 'key1'
	[[ "$REPLY" == 'mar' ]]

	toml.get_config_key 'key2'
	[[ "$REPLY" == 'bar' ]]

	toml.get_config_key 'key3'
	[[ "$REPLY" == 'far' ]]
}
