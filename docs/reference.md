# Reference


## Environment Variables

Use these to change the characteristics of how Glue operates

### `GLUE_CONFIG_USER`

The location of the global Glue configuration file. We comply with the XDG Base Directory specification, defaulting to a location of `~/.config/glue/glue.toml` if `GLUE_CONFIG_USER` is unset or a null string

### `GLUE_CONFIG_LOCAL`

The location of the local Glue configuration file. By default, it's `glue.toml`, relative to the current working directory

### `GLUE_STORE`

The location of your Glue store. This should be set in your Global configuration `init.sh` file, but you can override it. If no store is specified, the default is `~/.glue-store`

## `GLUE_NO_SWITCH_VERSION`

Do not switch the version of Glue. Usually, you wouldn't want this enabled, but it's useful when debugging Glue itself

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

The specified version of Glue. When this is specified, and the current version does not match, it will ensure Glue is cloned to `"${XDG_DATA_HOME:-$HOME/.local/share}/glue/repository"`, switch to the correct version, and execute with the same arguments. Valid versions include the full shasum of a Git commit, or a Git tag that represents a release

### Example

```toml
glueVersion = 'v0.9.0'
# or
glueVersion = '2414a21744785efafa2b97bc4137511671f13699'
```
