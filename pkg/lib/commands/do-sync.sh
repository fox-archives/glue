# shellcheck shell=bash

do-sync() {
	# ------------------------- Nuke ------------------------- #
	log.info "Nuking all files and dirs in '*/auto/'"
	mkdir -p "$GLUE_WD"/.glue/{output,generated}
	mkdir -p "$GLUE_WD"/.glue/{actions,tasks,util,configs}/auto
	find "$GLUE_WD"/.glue/{actions,tasks,commands,common,util,configs,output}/auto/ \
			-ignore_readdir_race -mindepth 1 -maxdepth 1 -print0 2>/dev/null \
		| xargs -r0 -- rm -rf

	# ------------------------- Copy ------------------------- #
	# ROOT
	log.info "Copying all files from '\$GLUE_STORE/root' to './'"
	find "$GLUE_STORE/root/" -ignore_readdir_race -mindepth 1 -maxdepth 1 -type f -print0 \
		| xargs -r0I '{}' -- cp '{}' "$GLUE_WD/.glue/"

	# UTIL
	log.info "Copying all files and dirs from '\$GLUE_STORE/util/' to 'util/'"
	find "$GLUE_STORE/util/" -ignore_readdir_race -mindepth 1 -maxdepth 1 -print0 \
		| xargs -r0I '{}' -- cp -r '{}' "$GLUE_WD/.glue/util/auto/"

	# TASKS
	log.info "Copying all files and dirs from '\$GLUE_STORE/tasks' to 'tasks/'"
	local projectTypeStr
	for projectType in "${GLUE_USING[@]}"; do
		projectTypeStr="${projectTypeStr}${projectType}\|"
	done
	[[ "${#GLUE_USING[@]}" -gt 0 ]] && projectTypeStr="${projectTypeStr:: -2}"
	find "$GLUE_STORE/tasks/" \
			-ignore_readdir_race -mindepth 1 -maxdepth 1 -type f \
			-regextype posix-basic -regex "^.*/\($projectTypeStr\)\..*$" -print0 \
		| xargs -r0I '{}' -- cp '{}' "$GLUE_WD/.glue/tasks/auto/"

	# ACTIONS, CONFIGS
	# <directoryToSearchAnnotations:annotationName:directoryToSearchForFile>
	local arg
	for arg in 'tasks:useAction:actions' 'actions:useAction:actions' 'actions:useConfig:configs'; do
		local searchDir= annotationName= fileDir=
		IFS=: read -r searchDir annotationName fileDir <<< "$arg"

		log.info "Copying proper files and dirs from '\$GLUE_STORE/$searchDir to '$fileDir/"

		local -a files=()
		readarray -d $'\0' files < <(find "$GLUE_WD"/.glue/"$searchDir"/{,auto/} -ignore_readdir_race -type f \
				-exec cat {} \; \
			| sed -Ene "s/^(\s*)?(\/\/|#)(\s*)?glue(\s*)?${annotationName}\((.*?)\)$/\5/p" - \
			| sort -u \
			| tr '\n' '\0'
		)

		# 'file' is a relative path
		for file in "${files[@]}"; do
			if [ -e "$GLUE_STORE/$fileDir/$file" ]; then
				case "$file" in
				*/*)
					# If file contains a directory path in it
					mkdir -p "$GLUE_WD/.glue/$fileDir/auto/${file%/*}"
					cp "$GLUE_STORE/$fileDir/$file" "$GLUE_WD/.glue/$fileDir/auto/${file%/*}"
					;;
				*)
					cp -r "$GLUE_STORE/$fileDir/$file" "$GLUE_WD/.glue/$fileDir/auto/"
				esac
			else
				log.warn "Corresponding file or directory for annotation '$annotationName($file)' not found in directory '$GLUE_STORE/$fileDir'. Skipping"
			fi
		done
	done
}
