#!/usr/bin/env bash

# TODO: move to own repository

# @description Get a particular key of a toml file
#
# @arg $1 value of key to store in $REPLY
# @arg $2 file to parse
toml.get_key() {
	local fn='toml.get_key'
	bootstrap.fn "$fn"

	local theirKey="$1"
	local file="$2"

	ensure.nonZero 'theirKey' "$theirKey"
	ensure.nonZero 'file' "$file"

	ensure.file "$file"

	while IFS= read -r line; do
		if [ "${line::1}" = '#' ]; then
			continue
		fi

		if [ -z "$line" ]; then
			continue
		fi

		shopt -s extglob

		key="${line%%=*}"
		key=${key##+( )}
		key=${key%%+( )}

		value="${line##*=}"
		value=${value##+( )}
		value=${value%%+( )}

		# hack to strip quotation marks
		# TODO: printf %q and only do one strip
		value="${value/#\'/}"
		value="${value/#\"/}"
		value="${value/%\"/}"
		value="${value/%\'/}"


		if [ "$key" = "$theirKey" ]; then
			REPLY="$value"
			break
		fi

	done < "$file"

	unbootstrap.fn
}
