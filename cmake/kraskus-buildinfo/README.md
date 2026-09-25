# kraskus-buildinfo

Copy of `cmake/cable/buildinfo` (cable v0.2.14, Apache-2.0, see `cmake/cable/LICENSE`) with one
change in `buildinfo.cmake`: the version string is **always** `<PROJECT_VERSION>+commit.<sha8>`
(`.dirty` appended for a modified tree), also when the checkout is exactly on the `v<version>`
tag. Upstream cable prints the bare version on a tag, which is why the 1.3.0 release binary
printed `kawpowminer 1.3.0` and failed the engine contract (`docs/ENGINE-CONTRACT.md`).
`CMakeLists.txt` points `cable_buildinfo_template_dir` here before `cable_add_buildinfo_library`.
