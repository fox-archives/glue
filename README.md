# glue

Glue is the manifestation of a generalized task runner with respect to language agnosticity

If you have a Node project, are you tired of the following monotonous tasks?

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

If you have a Go project, are you tired of the following monotonous tasks?

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
- Automate your cargo culting (or the configuration of best practices (however you interpret))

### Details

CURRENT STATE: BETA

For concrete examples see [glue-example](https://github.com/eankeen/glue-example) and it's respective [glue-store](https://github.com/eankeen/glue-store)

See [details.md](./docs/details.md)
