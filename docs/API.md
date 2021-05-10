# API

For executables ran in `actions`, `commands`, and `config`, the following environment variables are available

Most script-writing-gotchia's are due to the fact that the script file can reside in either `commands/auto/script.sh` or `commands/script.sh`

- GLUE_ACTIONS_DIR
- GLUE_COMMANDS_DIR
- GLUE_CONFIG_DIR
- GLUE_IS_AUTO (yes/no)
  - whether the script is currently being ran is in the 'auto' directory
