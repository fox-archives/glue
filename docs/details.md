# Details

For every project you want to use Glue with, a `.glue` directory is used to contain everything related to Glue: configuration, scripts, and script output.

There are two types of scripts: 'command' and 'action'. 'command' scripts can simply be though of the execution of a particular task relating to a programming language. For example: `Build Go library` or `Deploy Node server`. Each 'command' script calls out to an 'action' script that does the actual command. For example a script containaing `go build .` or `ansible-playbook playbook.yml`. Two categories of scripts exist to increase composability of 'actions' across languages (or even possibly domains!). Lastly, 'command' and 'action' scripts are contained in the `.glue/commands` and `.glue/actions` directories, respectively

The following explain the different parts of Glue, in no particular order

## Architecture

The generality of Glue and it's behavior keep the feature set and potential bugs to a minimal, but happens to significantly offload complexity to implementations of `actions` and `commands` scripts.

Because Glue is general, you can use any executable to evaluate your scripts (which is specifically why I mention executables having a file extension of `.*`). I use Bash, but of course you can use JavaScript, Python etc. In general, interpreted programming languages with dynamic imports and eval facilities _should_ play very nicely. Note that you wouldn't want to install external dependencies with a language-dependent package manger as that would make managing your Glue store _significantly_ more difficult

## Execution Flow

It's important to understand the execution flow of Glue when using the `cmd` subcommand to run a particular task. The following is an overview

1. When first invoking Glue, it looks for an `actions.bootstrap.*` and a `commands.bootstraps.*` file in the Glue store, setting their contents to `$GLUE_ACTIONS_BOOTSTRAP` and `$GLUE_COMMANDS_BOOTSTRAP`, respectively

2. If a task is specified through the `cmd` subcommand, it looks for that task in the `.glue/commands`, then `.glue/commands/auto` directories of your project. If none are found, it displays an error. See [Scripts](#scripts) for more details

3. Assuming the task is found, the file is executed, and the `$GLUE_ACTIONS_BOOTSTRAP`, `$GLUE_COMMANDS_BOOTSTRAP`, and `$GLUE_IS_AUTO` variables are passed into the environment. The rest of the execution is now dependent on the user's Glue store

## Scripts

Glue's process of finding and executing scripts makes script-writing easy to extend, modify, and compose. This functionality is only for scripts in the `commands` (not `actions`) directory.

A meta task is a combination of a Project Type, a Task, and a When. Not all components need to be present and not all compositional variations are valid

For example

```sh
# glue cmd [projectType]<.task>[-when]

glue cmd NodeJS_Server.build-before
```

`NodeJS_Server` is the project type, `build` is the task, and `before` is the 'when'

From this meta task, Glue searches for a script (ex. NodeJS_Server.build-before.sh`) in `.glue/commands/auto`. However, if one by the same name is found in `.glue/commands`, it uses that one instead

As you can see, script names are nearly identical to the meta task. The following code blocks lists all variations and their semantics

```sh
# Only task
glue cmd build
# Runs all 'build' scripts for all projectTypes specified in `build.sh`.
# This also runs the generic build script (ex. build.sh) last

# And projectType, task
glue cmd NodeJS_Server.build
# Runs all 'build' scripts for the NodeJS_Server project type. This
# also runs the generic build script (ex. build.sh) last

# And task, when
glue cmd NodeJS_Server-before
# Invalid because it doesn't make sense

# And projectType, task, when
glue cmd NodeJS_Server.ci-before
glue cmd NodeJS_Server.ci-only
```

### Project Type

```sh
glue cmd NodeJS_Server.build
```

Runs the 'build' script for the NodeJS_Server projectType

### When

```txt
commands/NodeJS_Server.build-before.sh
commands/NodeJS_Server.build.sh
commands/NodeJS_Server.build-after.sh
```

_Optionally_ add a 'when' to your meta task, which is a hyphen followed by either `before`, or `after`. In this example, it builds a NodeJS Server (ex. compiles TypeScript)

To execute all three in order:

```sh
glue cmd NodeJS_Server.build
```

To execute 'NodeJS_Server.build-before.sh`

```sh
glue cmd NodeJS_Server.build-before.sh
```

To execute _only_ `NodeJS_Server.build.sh`

```sh
glue cmd NodeJS_Server.build-only.sh
```

When is _super_ useful if you want to extend the funtionality of a script without changing it

For example, consider the following folder structure

```sh
commands/auto/NodeJS_Server.build.sh
commands/NodeJS_Server.build-after.sh
```

In this case, Glue will execute `NodeJS_Server.build.sh`, then `NodeJS_Server.build-after.sh`. By doing this, you extend the functionality of your build scripts. Note that omitting the 'When' portion would cause only the script in `commands/NodeJS_Server.build.sh` to execute

### Task

```sh
glue cmd build
```

This performs the build task for every projectType specified in your `glue.sh`.

For example, if in your `glue.sh`, you have `using=("NodeJS_Server Python")`, it will functionality be the same as the following

```sh
glue cmd NodeJS_Server.build
glue cmd Python.build
```
