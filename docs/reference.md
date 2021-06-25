# Reference


## Environment Variables

Use these to change the characteristics of how Glue operates

### `GLUE_CONFIG_USER`

The location of the global Glue configuration file. We comply with the XDG Base Directory specification, defaulting to a location of `~/.config/glue/glue.toml` if `GLUE_CONFIG_USER` is unset or a null string

### `GLUE_CONFIG_LOCAL`

The location of the local Glue configuration file. By default, it's `glue.toml`, relative to the current working directory

### `GLUE_STORE`

The location of your Glue store. This should be set in your Global configuration `init.sh` file, but you can override it. If no store is specified, the default is `~/.glue-store`

## Configuration for `glue.toml`

There are the parameters used by `Glue` itself; scripts in your Glue store may read different values from the file

## `storeDir`

Location of the Glue store. See mine [here](https://github.com/eankeen/glue-store)

### Example

```toml
storeDir = "~/repos/glue-store"
```

# `using`

Array of `projectType`s to use for the current project. These correspond to the names of files you place in the `tasks` subdirectory in your Glue store

### Example

```toml
using = ["Bash", "Docker"]
```

## Configuration for `glue-auto.toml`

This file is for data that you shouldn't have to manage. This includes version information that is automatically incremented, or will prompt you to increment itself. Like the `glue.toml` configuration, the following options are only used by `Glue`; more may be in use by your Glue store

### `glueVersion`

The specified version of Glue. When this is specified, it will checkout the repository at hash that is set before running any commands
