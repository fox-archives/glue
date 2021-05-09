# glue

Glue is the manifestation of a generalized task runner with respect to language agnosticity

If you have a Node project, are you tired of monotonous tasks:

- Integrating Husky/pre-commit with applicable bullets
- Integrating lint-staged
- Running Jest/Ava tests and generating code coverage
- Hooking up Prettier/eslint linting
- Automatically versioning each build
- Uploading build artifacts to a particular registry
- Create a documentation website
- Creating/building/uploading Docker images
- Configuring CI
- etc.

If you have a Go project, are you tired of monotonous tasks:

- Setting up goreleaser
- Integrating Husky/pre-commit with applicable bullets
- Running tests
- Hooking up golangci-lint
- Automatically versioning each build
- Creating/building/uploading Docker images
- Packaging/Distributing your app in the form of a Snap, Debian package, AppImage, etc.
- Configuring CI
- etc.

Indeed, `cookiecutter`, `yeoman`, and project template generators help, but if you want to add functionality to the boilerplate files, you have to add it to every single project manually (as well, of course, to the boilerplate repository/directory) since localized configuration drift is inveitable.

If you use `glue` and wish to add functionality that is generalized enough for most projects of a particular language, simply edit the boilerplate, and run a command in each project for new changes to reflect. They are reflected in the `.glue` folder, which resides at project root. Some features of `glue` include

- Easy escape hatches are provided if you wish to overide or modify any generalizations
- Written in pure Bash
- Configuration decoupled from traditional locations of configuration (everything is isolated in `.glue`)

### Details

CURRENT STATE: PRE-ALPHA

The generalized want of the aforementioned issues include a pre-configured way to `build`, run `ci`, `release`, and `deploy` your programming project. Each pre-configuration (ex. bash executable) is usually taylored to a particular programming language and uses abstracts of running actual actual commands, like `eslint`, or `clang-tidy`. For example, a Node `glue release` command runs a bash executable, which in turn, executes another shell script that actually runs `npm build` and `npm release`. The primary purpose of this shell script intermetiary layer is to increase composability and parameterize the running of the underlying command, if sufficient warranty exists. This may be useful, for example (albeit quite contrived), if you wish to use [prettier](https://prettier.io) for a Node project, but reuse that invocation script for a Java project.

Configuration is separated in three subfolders of `.glue`: `actions`, `commands`, and `config`. Each folder represents a major portion of execution flow within the program. When you run something like `glue build` for a `node` project, it scours the `./glue/commands` directory for the following files, in order: `['node-build-before.sh', 'node-build.sh', 'node-build-after.sh', 'build-before.sh', 'build.sh', 'build-after.sh]` (other executables like `node-build.py` are interchangeable, at least in theory). A particular one of those executables might contain an invocation to a file like `actually-do-npm-build.sh`, or `actually-exec-prettier.sh` which will reside in `./.glue/actions`. These shell scripts, in turn, read configuration located in `./.glue/config` such as `prettier.config.json` or `goreleaser.yml`
