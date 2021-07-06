# shellcheck shell=bash

do-list() {
	local -a tasks=()

	local filePath
	for filePath in "$GLUE_WD"/.glue/tasks/* "$GLUE_WD"/.glue/tasks/auto/*; do
		if [ -d "$filePath" ]; then
			continue
		fi

		local file="${filePath##*/}"

		# Ensure entry does not already exist
		local existingFile
		for existingFile in "${tasks[@]}"; do
			if [ "$existingFile" = "$file" ]; then
				continue 2
			fi
		done

		tasks+=("$file")
	done

	local -r indent="    "
	local task= previousProjectType=
	local -a generalTasks=()

	local -r sortedTasks="$(
		for task in "${tasks[@]}"; do
			printf "%s\n" "$task"
		done | sort
	)"
	while IFS=. read -r projectType task fileEnding; do
		# echo j "$task"
		# If fileEnding is empty, it means the file looks like 'Bash.build.sh'
		# rather than 'build.sh', so we save for printing the general for later
		if [[ -z "$fileEnding" ]]; then
			generalTasks+=("$projectType")
			continue
		fi

		if [ "$previousProjectType" != "$projectType" ]; then
			printf "${previousProjectType:+$'\n'}%s:\n" "$projectType"

			previousProjectType="$projectType"
		fi

		printf "$indent%s\n" "$task"
	done <<< "$sortedTasks"

	if [ "${#generalTasks[@]}" -gt 0 ]; then
		printf "${previousProjectType:+$'\n'}%s\n" "General:"
		printf "$indent%s\n" "${generalTasks[@]}"
	fi
}
