The example in this folder illustrates how to share tool-resolution logic
between `hook/build.dart` and `hook/doctor.dart`:

* [cli_tool/](cli_tool/) contains a package whose `hook/build.dart` runs an
  external command-line tool (`git`) from `PATH`, and whose `hook/doctor.dart`
  uses the same resolution function to validate that the tool is installed on
  `PATH`.

