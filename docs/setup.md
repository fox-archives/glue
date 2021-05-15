# Setup

## Global Configuration

It is recommended to create a file at `~/.config/glue/init.sh`, containing the location of your Glue store.

```bash
store="$HOME/repos/glue-store"
```

## Local Configuration

For every project you wish to manage with `Glue`, create a `glue.sh` at the root of the directory. It contains the project types you wish to use. These are ran in order.

For example, if you specify `glue cmd build`, it will first execute `./commands/NodeJS_Server.build.sh`, then `./commands/Python.build.sh` (in addition to potentially executing many other scripts, which isn't important here for brevity's sake)

```bash
# shellcheck shell=bash

# shellcheck disable=SC2034
using=("NodeJS_Server" "Python")
```

## Environment Variables

Use these to change the characteristics of how Glue operates

### `GLUE_INIT_FILE`

The location of the global glue configuration file. By default it's at `~/.config/glue/init.sh`

### `GLUE_STORE`

The location of your Glue store. This should be set in your Global configuration `init.sh` file, but you can override it. If no store is specified, the default is `~/.glue-store`
