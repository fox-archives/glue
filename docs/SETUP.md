# SETUP.md

## Environment Variables

- `GLUE_INIT_FILE`

  - default: `~/.config/glue/init.sh`

- `GLUE_STORE`
  - default: `~/.glue-store` (this should be set in the init file)

## Init file

This is sourced near the beginning of the script. Set the following variables

`store`

- set the store path

### Example

```bash
readonly store="$HOME/repos/glue-store"
```
