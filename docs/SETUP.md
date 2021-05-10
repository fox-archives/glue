# SETUP.md

## Global Configuration

It is recommended to create a file at `~/.config/glue/init.sh`, containing the location of your Glue store.

```bash
store="$HOME/repos/glue-store"
```

## Local Configuration

For every project you wish to manage with `Glue`, create a `glue.sh` at the root of the directory, that contains which template types / project types you wish to use. These are ran in order when you execute a task without naming a specific template type / project type on the command line

```bash
# shellcheck shell=bash

# shellcheck disable=SC2034
using=("NodeJS_Server" "Python")
```

## Environment Variables

- `GLUE_INIT_FILE`

  - default: `~/.config/glue/init.sh`

- `GLUE_STORE`
  - default: `~/.glue-store` (this should be set in the init file)
