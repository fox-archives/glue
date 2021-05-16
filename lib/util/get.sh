# shellcheck shell=bash

# Get the current working directory of the project. We
# use this so we can get an absolute path to the current
# project (rather than being relative to `$PWD`)
get.wd() {
	while [[ ! -f "glue.sh" && "$PWD" != / ]]; do
		cd ..
	done

	if [[ $PWD == / ]]; then
		die 'No glue config file found in current or parent paths'
	fi

	printf "%s" "$PWD"
}

# 'cd' to set the working directory of this Bash process to the same one
# containing the 'glue.sh' file
set.wd() {
	while [[ ! -f "glue.sh" && "$PWD" != / ]]; do
		cd ..
	done

	if [[ $PWD == / ]]; then
		die 'No glue config file found in current or parent paths'
	fi
}

# Return the name of the 'task'
get.task() {
	local task="$1"
	REPLY=

	task="${task##*.}"
	task="${task%%-*}"

	REPLY="$task"
}

# Return the name of the 'projectType'
get.projectType() {
	local projectType="$1"
	REPLY=

	# projectType exists iff . exists
	if [[ $projectType == *.* ]]; then
		projectType="${projectType%%.*}"
		REPLY="$projectType"
	fi
}

# Return the name of 'when'
get.when() {
	local when="$1"
	REPLY=

	if [[ $when == *.* ]]; then
		when="${when##*.}"
	fi

	if [[ $when == *-* ]]; then
		when="${when##*-}"
	fi

	REPLY="$when"
}
