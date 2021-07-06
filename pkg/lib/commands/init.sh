# shellcheck shell=bash

do-init() {
	if [ -f glue.toml ]; then
		log.warn "File 'glue.toml' already exists. Not overwriting"
	else
		cat >| 'glue.toml' <<-"EOF"
		using = []

		name = ''
		email = ''
		project = ''
		description = ''
		license = ''
		EOF
	fi

	if [ -f glue-auto.toml ]; then
		log.warn "File 'glue-auto.toml' already exists. Not overwriting"
	else
		cat >| 'glue-auto.toml' <<-"EOF"
		glueVersion = ''

		storeVersion = ''

		programVersion = ''
		EOF
	fi
}
