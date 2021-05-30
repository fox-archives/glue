# shellcheck shell=bash
# @file get.sh
# @brief Getters and parser functions
# @description Contains getters for shell state and parsing meta tasks

# @description Get the current working directory of the project. We
# use this so we can get an absolute path to the current
# project (rather than being relative to `$PWD`)
#
# @stdout Working directory of the project
get.wd() {
	while [[ ! -f "glue.toml" && "$PWD" != / ]]; do
		cd ..
	done

	if [[ $PWD == / ]]; then
		die "No glue config file 'glue.toml' found in current or parent paths"
	fi

	printf "%s" "$PWD"
}

# @description 'cd' to set the working directory of this Bash process to the same one
# containing the 'glue.toml' file
set.wd() {
	while [[ ! -f "glue.toml" && "$PWD" != / ]]; do
		cd ..
	done

	if [[ $PWD == / ]]; then
		die "No glue config file 'glue.toml' found in current or parent paths"
	fi
}

# @description Return the name of the 'task'
get.task() {
	local task="$1"
	REPLY=

	task="${task##*.}"
	task="${task%%-*}"

	REPLY="$task"
}

# @description Return the name of the 'projectType'
get.projectType() {
	local projectType="$1"
	REPLY=

	# projectType exists iff . exists
	projectType="${projectType%%.*}"

	if [ "$projectType" = "$1" ]; then
		projectType=
	fi

	REPLY="$projectType"
}

# @description Return the name of 'when'
get.when() {
	local when="$1"
	REPLY=

	when="${when##*-}"

	if [ "$when" = "$1" ]; then
		when=
	fi

	REPLY="$when"
}
