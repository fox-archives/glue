# shellcheck shell=bash
# shellcheck disable=SC2164

load 'util/create.sh'

export PATH="$PWD/pkg/bin:$PATH"

export GLUE_NO_SWITCH_VERSION=

setup() {
	local dir="$BATS_TMPDIR/glue/${BATS_TEST_NUMBER}_$BATS_TEST_NAME"
	mkdir -p "$dir"
	cd "$dir"
}

teardown() {
	cd "$BATS_TMPDIR/glue"

	local dir="$BATS_TMPDIR/glue/${BATS_TEST_NUMBER}_$BATS_TEST_NAME"
	rm -rf "$dir"
}
