# Setup

Both Global and Local configuration have the same file format. Put something in the Global configuration only where it doesn't make sense to put in the local one.

## User Configuration

It is recommended to create a file at `~/.config/glue/glue.toml` (`GLUE_CONFIG_USER`), containing the location of your Glue store. The `~`, along with `$XDG_CONFIG_HOME` and `$XDG_DATA_HOME` values are interpolated to their environment variable equivalents

```bash
storeDir = "~/repos/glue-store"
```

## Local Configuration

For every project you wish to manage with `Glue`, create a `glue.toml` at the root of the directory. It contains the project types you wish to use. These are ran in order.

For example, if you specify `glue cmd build`, it will first execute `./tasks/NodeJS_Server.build.sh`, then `./tasks/Python.build.sh` (in addition to potentially executing many other scripts, which isn't important here for brevity's sake)

```toml
# TODO: make array work
using=["NodeJS_Server", "Python"]
```
