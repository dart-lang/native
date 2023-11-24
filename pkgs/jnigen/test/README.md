## How to run tests?
#### One-time setup:
```
dart run jnigen:setup
```

#### Running tests
```sh
dart run tool/generate_runtime_tests.dart ## Regenerates runtime test files
dart test
```

Note: Tests fail if summarizer is not previously built and 2 tests try to build it concurrently. We have to address it using a lock file and exponential backoff (#43). Temporarily, run `dart run jnigen:setup` before running tests for the first time.
