# API

For executables ran in `actions` and `commands`, the following environment variables are available

## Environment Variables

### `GLUE_WD`

An absolute path to the current project. In other words, the directory that contains the `.glue` directory

### `GLUE_IS_AUTO`

Whether or not the currently running script has a parent folder of 'auto'. Has a value of either `yes` or `no`.

### GLUE_COMMANDS_BOOTSTRAP

The stage 1 bootstrap commands to executed when a script under the 'commands' directory executes or is sourced

### GLUE_ACTIONS_BOOTSTRAP

The stage 1 bootstrap commands to be executed when a script under the 'actions' directory executes or is sourced

## Directories

Certain directories have an intrinsic meaning and should be used as such. All directories are a subdirectory of `.glue` and should be tracked by your VCS

### `commands`

The location Glue looks to execute a particular task. Glue also scans this directory to find `requireAction()` annotations

### `actions`

The location a script in 'commands' looks to source to perform a more fine-grained action (ex. run `eslint`). Glue also scans this directorie to find `requireConfig()` annotations

### `configs`

Where config files are stored. Glue doesn't use this file directly, but it copies its contents because your scripts will likely require configuration

### `common`

Scripts in `common` contain functionality shared by both scripts in `commands` and `actions`. Glue doesn't use this file directly, but it copies its contents nevertheless

### `output`

Any output that your scripts may emit. Since this directory is one of the only ones (besides `state`) that is not contained in the Glue store, it should not have an `auto` subdirectory

### `state`

Any persistent state that your scripts may emit. Use of this directory is _highly discouraged_. Just like `output`, there should not be a subdirectory of `auto`

# Miscellaneous

Most script-writing-gotchia's are due to the fact that the script file can reside in either `commands/auto/script.sh` or `commands/script.sh`

- Note that for example, when `commands/auto/script.sh` runs, GLUE_ACTIONS_DIR may be different on first pass. This is due to the eval of `GLUE_ACTIONS_BOOTSTRAP`. So, only use these variables in functions

# Store

- Any executable, recommended a shellscript with a shebang, but other interpreters with shebangs or something marked with bimfmt_misc will work as well

## Commands

## Actions
