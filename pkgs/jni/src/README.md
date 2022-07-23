## LSP instructions

If using an LSP based editor plugin and the syntax highlighting / code completion is not working, there are 2 ways to fix that.

* __Create a compile_flags.txt with following content__:

`-I<path_to_folder_containing_jni_headers>`

This might need the OS specific include folder as well, so that transitively included headers can be found. Example:

```
-I/usr/lib/jvm/java-11-openjdk-amd64/include
-I/usr/lib/jvm/java-11-openjdk-amd64/include/linux
```

Note that this file should contain one compilation flag per line.

* __create a compilation database by prefixing `bear` to your cmake build__.

Run `cmake --build` command from your source, prefixed with `bear`.

`bear -- cmake --build <build_dir>`

On some distro versions of `bear` command, the `--` needs to be omitted.

`bear cmake --build <build_dir>`

