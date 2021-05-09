# zest

# TODO: description

Zest up heterogenous components of the local segment of the Software Development Lifecycle by synergizing your toolchain, primarily with cross-utility interoperability and easing the integration of auxillary and ancillary development tools

Use Case / User Story

# TODO

Jim sets up a quick programing project with $LANGUAGE. Within tens of minutes, they are ready to ship the first version. However, setting up a build pipeline takes longer than it took to build the first version. Boilerplate solutions like `cookiecutter` and `yeoman` help, but they have their own APIs, doesn't update if you make any improvements (ex. for example if you want to integrate docker, you have to re-copy boilerplate Dockerfiles or docker-compose.yml scripts to those projects)

`zest` automates that. It copies boilerplate build, lint, testing, etc. shell script files to your project, and any chanages in the original will be reflected (via copy). It has clean escape hatches so you can just define your own linting script, or easily define scripts to run when you `just build`

# TODO: make paths absolute to project directory, rather than based on cwd
