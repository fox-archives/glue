# Reference


## Environment Variables

Use these to change the characteristics of how Glue operates

### `GLUE_CONFIG_USER`

The location of the global Glue configuration file. We comply with the XDG Base Directory specification, defaulting to a location of `~/.config/glue/glue.toml` if `GLUE_CONFIG_USER` is unset or a null string

### `GLUE_CONFIG_LOCAL`

The location of the local Glue configuration file. By default, it's `glue.toml`, relative to the current working directory

### `GLUE_STORE`

The location of your Glue store. This should be set in your Global configuration `init.sh` file, but you can override it. If no store is specified, the default is `~/.glue-store`
