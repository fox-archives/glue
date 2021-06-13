# [0.8.0](https://github.com/eankeen/glue/compare/v0.7.0+ad7f095-DIRTY...v0.8.0) (2021-06-13)


### Bug Fixes

* regex to read 'version' key surroundned by single quotes ([a6030e9](https://github.com/eankeen/glue/commit/a6030e9d5755416a4266d31e17cb665e018f48b0))
* Update variable to use when sourcing based on new Glue store ([b04caea](https://github.com/eankeen/glue/commit/b04caea6b804f5776637cc00feed3d40f2b44bd9))



# [0.7.0+ad7f095-DIRTY](https://github.com/eankeen/glue/compare/v0.7.0...v0.7.0+ad7f095-DIRTY) (2021-05-30)


### Bug Fixes

* Hotfix greping 'using' key in `glue.toml` hack ([9aca498](https://github.com/eankeen/glue/commit/9aca498ba0b0d0005cdcd415987bc37d677fa3fc))



# [0.7.0](https://github.com/eankeen/glue/compare/v0.6.0...v0.7.0) (2021-05-27)


### Bug Fixes

* errors that have purported to end script now exit program properly ([50606a6](https://github.com/eankeen/glue/commit/50606a624ab4ca28eab922770509df193bbda66f))
* invocation works not just at root ([7cc7658](https://github.com/eankeen/glue/commit/7cc765804e1bd50d56be65913fd0047801fefbe6))
* language agnostic scripts now execute ([9eaf05f](https://github.com/eankeen/glue/commit/9eaf05f1b4c55672d4ff4e19f19ea59ff731d8c4))
* only exec bootstrap files when needed ([aba16ef](https://github.com/eankeen/glue/commit/aba16ef7d5ce192314dca5ae6fbedb8296a44a1d))
* show error when 'cmd' subcommand does not match with '.glue' 'commands' ([16ef66c](https://github.com/eankeen/glue/commit/16ef66c82ff1d3781c7f1e7fd0205b37ac2bf086))
* sync works properly ([6e71fc5](https://github.com/eankeen/glue/commit/6e71fc5044e3a82e75e33ada326474d4dc6e8691))
* using 'when' specifically now works ([c4bac3d](https://github.com/eankeen/glue/commit/c4bac3ddc09b40068838702e88d430688029823d))
* wrong conditional for loading local glue.sh file ([9c48186](https://github.com/eankeen/glue/commit/9c481866c22e89e6daa8e381b47edd2b6e89aa41))
* wrong languages used / ordering ([fc57177](https://github.com/eankeen/glue/commit/fc57177224e96ad00e773dbfd15b6d35204ad7f8))


### Features

* add 'sync' command and do other things ([b237bfd](https://github.com/eankeen/glue/commit/b237bfd8717676c5c237d9f66b5f842a8581410a))
* add Glue ([afd5ad3](https://github.com/eankeen/glue/commit/afd5ad3f13cd174bf7d3606022fa8d3f1c39a364))
* add print command that does not work ([b349e5b](https://github.com/eankeen/glue/commit/b349e5b3a3a87e478f426c6f9d27c2313f3c2c38))
* copy over actions and configs ([182c7e2](https://github.com/eankeen/glue/commit/182c7e2d76969c186c5a9a834856e5190e957446))
* glue can run command scripts for particular language ([8fc04f1](https://github.com/eankeen/glue/commit/8fc04f1221b7bca944c270bae352a19ddcd7fc29))
* knock off multiple TODOs ([c69e18c](https://github.com/eankeen/glue/commit/c69e18c965d60be9de8928e469c2b34a0a3b8b6c))
* only copy over applicable commands ([e754798](https://github.com/eankeen/glue/commit/e7547984739c93884e9b86a881551a2a03f2e650))
* optimize doSync and fix some files not copying ([845e135](https://github.com/eankeen/glue/commit/845e13586a654be6f88e65e0e0ce924bf1b7a7ac))
* pass string to exec on bootstrap of a command/action ([90a2e84](https://github.com/eankeen/glue/commit/90a2e84f9f5402bec01b05c1afd1a4a2b1bc0b1b))
* print copied files in sync subcmd ([6a86d8f](https://github.com/eankeen/glue/commit/6a86d8fd983543715b686c58be84ebd91722abcc))
* update format of command filenames to be more readable ([e47014e](https://github.com/eankeen/glue/commit/e47014ef98e6689397873e006c14d9ee5dcf2734))
* use only single bootstrap.* file in Glue store ([9c3a443](https://github.com/eankeen/glue/commit/9c3a443a0c21573a53cafa01ae5871fa6549b224))



