# flow.md

It's important to understand the execution flow of Glue when using the `cmd` subcommand to run a particular task. The following is an overview

1. When first invoking Glue, it looks for an `actions.bootstrap.*` and a `commands.bootstraps.*` file in the Glue store, setting their contents to `$GLUE_ACTIONS_BOOTSTRAP` and `$GLUE_COMMANDS_BOOTSTRAP`, respectively

2. If a task is specified through the `cmd` subcommand, it looks for that task in the `.glue/commands`, then `.glue/commands/auto` directories of your project. If none are found, it shows an error

3. Assuming the task is found, the file is executed, passing in `$GLUE_ACTIONS_BOOTSTRAP`, `$GLUE_COMMANDS_BOOTSTRAP`, and `$GLUE_IS_AUTO` as environment variables. The rest of the execution is now dependent on the user's Glue store

This architecture significantly offloads complexity to the command/action script implementation

Note that execution means execution; shell scripts, JavaScript, etc. files can be used and executed. In general, interpreted programming languages with dynamic imports and eval facilities should play very nicely
