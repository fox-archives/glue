#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

ensure.cmd 'shdoc'

util.shopt -s dotglob
util.shopt -s nullglob

for file in **/*{.sh,bash}; do
	:
done

unbootstrap
