# shellcheck shell=bash

trap sigint INT
sigint() {
	die 'Received SIGINT'
}
