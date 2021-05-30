# API

For executables ran in `actions` and `commands`, the following environment variables are available

## `glue.toml`

The `glue.toml` can be expected to have the following configuration

### `name`

Name of the project. This is a pretty name

### `using`

String or array of `projectType`s to use

## `glue-auto.toml`

File that contains project specific configuration data only read and updated by scripts

### `version`

Current [Semantic Version](https://semver.org) of the project

## Environment Variables

### `GLUE_WD`

An absolute path to the current project. In other words, the directory that contains the `.glue` directory

### `GLUE_IS_AUTO`

Whether or not the currently running script has a parent folder of 'auto'. Has a value of either `yes` or `no`.

### `GLUE_BOOTSTRAP`

The stage bootstrap commands to executed when a script under the 'commands' or 'actions' directory executes or is sourced. This has the contents of the `boostrap.*` file in your Glue store

## Directories

Certain directories have an intrinsic meaning and should be used as such. All directories are a subdirectory of `.glue` and should be tracked by your VCS

### `commands`

The location Glue looks to execute a particular task. Glue also scans this directory to find `useAction()` annotations

### `actions`

The location a script in 'commands' looks to source to perform a more fine-grained action (ex. run `eslint`). Glue also scans this directorie to find `useConfig()` annotations

### `configs`

Where config files are stored. Glue doesn't use this file directly, but it copies its contents because your scripts will likely require configuration

### `common`

Scripts in `common` contain functionality shared by both scripts in `commands` and `actions`. Glue doesn't use this file directly, but it copies its contents nevertheless

### `output`

Any output that your scripts may emit. Since this directory is one of the only ones (besides `state`) that is not contained in the Glue store, it should not have an `auto` subdirectory

### `generated`

Any temporary or permanent files your (action) script may emit. Please namespace all of your files under the `action` script name. For example, generate under `tool-shdoc` for `actions/tool-shdoc.sh`

### `root`

This file is only present in the Glue store. All _files_ it contains is copied to the `.glue/` directories. Primarily, this is used to house a `.gitignore` for the `generated` subdirectory

# Miscellaneous

- Most script-writing-gotchia's are due to the fact that the script file can reside in either `commands/auto/script.sh` or `commands/script.sh`
