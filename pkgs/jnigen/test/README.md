Some notes about tests in this directory:

* [jackson_core_test](jackson_core_test/) is an end-to-end test which generates bindings for `jackson_core` library using the whole jnigen pipeline and compares the generated bindings with expected bindings. [simple_package_test](simple_package_test/) is similar but instead of using a Java library from maven, uses a stub java class.
* [bindings_test.dart](bindings_test.dart) runs the generated bindings to make sure they work. There are only a few tests here right now.
* [test_util/](test_util/) directory contains some code common to both `jackson_core_test` and `simple_package_test`. (Especially the functions `generateAndCompareBindings` and `generateAndAnalyzeBindings`).
* [yaml_config_test.dart](yaml_config_test.dart) runs the same `jackson_core` configuration but through YAML and makes sure it generates the same bindings.
* The other files contain unit tests for some error-prone components.

Note: Tests fail if summarizer is not previously built and 2 tests try to build it concurrently. We have to address it using a lock file and exponential backoff (#43). Temporarily, run `dart run jnigen:setup` before running tests for the first time.

TODO(#62): Add some unit & integration tests in the java portion.
