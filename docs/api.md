# API

For executables ran in `actions`, `commands`, and `configs`, the following environment variables are available

- GLUE_WD

- GLUE_IS_AUTO (yes/no)

  - whether the script is currently being ran is in the 'auto' directory

- GLUE_COMMANDS_BOOTSTRAP
- GLUE_ACTIONS_BOOTSTRAP

Most script-writing-gotchia's are due to the fact that the script file can reside in either `commands/auto/script.sh` or `commands/script.sh`

- Note that for example, when `commands/auto/script.sh` runs, GLUE_ACTIONS_DIR may be different on first pass. This is due to the eval of `GLUE_ACTIONS_BOOTSTRAP`. So, only use these variables in functions

# Store

- Any executable, recommended a shellscript with a shebang, but other interpreters with shebangs or something marked with bimfmt_misc will work as well

## Commands

## Actions
