# API

For executables ran in `actions`, `commands`, and `configs`, the following environment variables are available

- GLUE_COMMANDS_DIR
- GLUE_ACTIONS_DIR
- GLUE_CONFIGS_DIR

- GLUE_COMMANDS_BOOTSTRAP
- GLUE_ACTIONS_BOOTSTRAP

- GLUE_IS_AUTO (yes/no)
  - whether the script is currently being ran is in the 'auto' directory

Most script-writing-gotchia's are due to the fact that the script file can reside in either `commands/auto/script.sh` or `commands/script.sh`

- Note that for example, when `commands/auto/script.sh` runs, GLUE_ACTIONS_DIR may be different on first pass. This is due to the eval of `GLUE_ACTIONS_BOOTSTRAP`. So, only use these variables in functions
