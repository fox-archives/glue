#!/usr/bin/env bash
eval "$GLUE_BOOTSTRAP"
bootstrap || exit

ensure.cmd 'shellcheck'

util.shopt -s dotglob
util.shopt -s nullglob

shellcheck --check-sourced -- ./**/*.{sh,bash}

unbootstrap
