# Glue Version Switch

When `Glue` starts, it will attempt to switch to the version of `Glue` specified in `glue-auto.toml`

It does this by managing two sets of `Glue` repositories. One called `repository` and another called `versions`, which are both in `"${XDG_DATA_HOME:-$HOME/.local/share}/glue"`

## `repository`

This directory contains the full history of `Glue`. Every `Glue` switches versions, it will update this repository to the latest possible version

## `versions`

This directory contains subdirectories of different `Glue` versions. For each unique version specified in a particular `glue.toml` file, there will be a corresponding version in this directory. In this directory, the repositories are cloned with `--depth=1` to minimize its size
