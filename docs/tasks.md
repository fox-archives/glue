# Tasks

## sync

Copies files from the Glue store to the current project's `.glue` folder. First, it removes every file and foldler under all `auto` directories. Then, it copies all files and folders under `util`. Next, it copies `tasks` scripts that match all projectTypes specified in `glue.toml`. Lastly, it copies files and directories specified with `useAction(...)` and `useConfig(...)` annotations

## list

## print


# act

Executes a particular script under `actions`. Specify the actionFile directly, without the extension

# cmd

Executes a particular script under `tasks`. Specify a metaTask to match a particular set of files
