#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap

action() {
	ensure.cmd 'toast'

	util.shopt -s globstar

	local exitCode=0

	toml.get_key 'gitRemoteUser' glue.toml
	local gitRemoteUser="$REPLY"

	toml.get_key 'gitRemoteRepo' glue.toml
	local gitRemoteRepo="$REPLY"

	bootstrap.generated 'tool-mkdocs'
	ensure.cd "$GENERATED_DIR"

	# TODO: only import docs
	git clone --depth 1 file://"$GLUE_WD" .

	# glue useConfig(tool-mkdocs)
	util.get_config 'tool-mkdocs/mkdocs.yml'
	local cfgMkdocsYml="$REPLY"

	util.get_config 'tool-mkdocs/pyproject.toml'
	local cfgPyprojectToml="$REPLY"

	util.get_config 'tool-mkdocs/toast.yml'
	local cfgToastYml="$REPLY"

	cp "$cfgMkdocsYml" "$cfgPyprojectToml" "$cfgToastYml" .

	ensure.file "$GLUE_WD/README.md"
	cp "$GLUE_WD/README.md" 'docs/index.md'

	# Copy specialized files to 'docs' before build
	util.run_hook 'hook.tool-mkdocs.copy_docs'

	toast mkdocs
	cp -r "$GENERATED_DIR/site" "site"

	ensure.cd site
	git init --initial-branch=main
	git add -A
	# TODO: commit message
	git commit -m 'Update site'
	# TODO: rebase or configure merge strategy
	git push -f "https://github.com/$gitRemoteUser/$gitRemoteRepo.git" main:gh-pages
	unbootstrap.generated

	REPLY="$exitCode"
}

action "$@"
unbootstrap
