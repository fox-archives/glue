#!/usr/bin/env bats

load 'util/init.sh'

@test util.get_config_string {
	GLUE_CONFIG_USER="glue-user.toml"
	GLUE_CONFIG_LOCAL="glue-local.toml"

	cat > glue-user.toml <<-"EOF"
	key1 = 'blah'
	key2 = 'bar'
	EOF

	cat > glue-local.toml <<-"EOF"
	key1 = 'mar'
	key3 = 'far'
	EOF

	util.get_config_string 'key1'
	[ "$REPLY" = 'mar' ]

	util.get_config_string 'key2'
	[ "$REPLY" = 'bar' ]

	util.get_config_string 'key3'
	[ "$REPLY" = 'far' ]
}
