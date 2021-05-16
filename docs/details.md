# Details

For every project you want to use Glue with, a `.glue` directory is used to contain everything related to Glue: configuration, scripts, and script output.

There are two types of scripts: 'command' and 'action'. 'command' scripts can simply be though of the execution of a particular task relating to a programming language. For example: `Build Go library` or `Deploy Node server`. Each 'command' script calls out to an 'action' script that does the actual command. For example `go build .` or `ansible-playbook playbook.yml`. Two categories of scripts exist to increase composability of 'actions' across languages (or even possibly domains!). Lastly, 'command' and 'action' scripts are contains in the `.glue/commands` and `.glue/actions` directories, respectively

The following explain the different parts of Glue, in no particular order

## Architecture

The generality of Glue and it's behavior keep the feature set and potential bugs to a minimal, but happens to significantly offload complexity to implementations of `actions` and `commands` scripts.

Because Glue is general, you can use any executable to evaluate your scripts (which is specifically why I mention executables having a file extension of `.*`). I use Bash, but of course you can use JavaScript, Python etc. In general, interpreted programming languages with dynamic imports and eval facilities _should_ play very nicely. Note that you wouldn't want to install external dependencies with a language-dependent package manger as that would make managing your Glue store _significantly_ more difficult

## Execution Flow

It's important to understand the execution flow of Glue when using the `cmd` subcommand to run a particular task. The following is an overview

1. When first invoking Glue, it looks for an `actions.bootstrap.*` and a `commands.bootstraps.*` file in the Glue store, setting their contents to `$GLUE_ACTIONS_BOOTSTRAP` and `$GLUE_COMMANDS_BOOTSTRAP`, respectively

2. If a task is specified through the `cmd` subcommand, it looks for that task in the `.glue/commands`, then `.glue/commands/auto` directories of your project. If none are found, it displays an error. See [Finding Scripts](## Finding Scripts) for more details

3. Assuming the task is found, the file is executed, and the `$GLUE_ACTIONS_BOOTSTRAP`, `$GLUE_COMMANDS_BOOTSTRAP`, and `$GLUE_IS_AUTO` variables are passed into the environment. The rest of the execution is now dependent on the user's Glue store

## Finding Scripts

Glue's process of finding and executing a script file in accordance to a user's specified meta task makes script-writing easy to extend and modify. This functionality is only for scripts in `commands`, _not_ `actions` (you would have to implement it yourself).

A meta task is a combination of a Project Type, a Task, and a When

For each of the following headings, a file structure and commands to execute those particular files are shown.

Note that Glue looks for a particular script (ex. NodeJS_Server.build.sh`) in `.glue/commands/auto`. However, if one by the same name is found in `.glue/commands`, it uses that instead

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

### Project Type

```sh
glue cmd NodeJS_Server
```

TODO: This shouldn't do anything and return an error. It doesn't make sense to execute all tasks associated with a projectType in order.

### No Project Type and No Task

```sh
glue cmd build
```

This performs the [Project Type and Task](###project-type-and-task) steps for every projectType specified in your `glue.sh`.

For example, if in your `glue.sh`, you have `using=("NodeJS_Server Python")`, it will functionality be the same as typing

```sh
glue cmd NodeJS_Server.build
glue cmd Python.build
```

## Script Names

Scripts have to be named a particular way for Glue to discover them. It meant to be nearly identical to the argument specified when using the subcommand `cmd`. The following shows the format

TODO: check to be sure all of these are valid

```txt
[projectType]<.task>[-when].<fileExtension>

- With all the parts:
NodeJS_Server.ci-before.sh

- With only 'projectType' missing
ci-before.sh

- With only 'when' missing
NodeJS_Server.ci.sh

- With both 'projectType' and 'when' missing
ci.sh
```

To know which scripts are executed in which order, see [Finding Scripts](##finding-scripts)
