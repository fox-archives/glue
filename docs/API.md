# API

For executables ran in `actions`, `commands`, and `config`, the following environment variables are available

Most script-writing-gotchia's are due to the fact that the script file can reside in either `commands/auto/script.sh` or `commands/script.sh`

- Note that for example, when `commands/auto/script.sh` runs, GLUE_ACTIONS_DIR may be different on first pass. This is due to the eval of `GLUE_BOOTSTRAP_ACTIONS`. If you use these values in functions, you should be good

- GLUE_ACTIONS_DIR
- GLUE_COMMANDS_DIR
- GLUE_CONFIG_DIR
- GLUE_IS_AUTO (yes/no)
  - whether the script is currently being ran is in the 'auto' directory
