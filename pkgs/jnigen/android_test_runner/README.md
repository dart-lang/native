## What's this?

This is Flutter app project which serves as a skeleton for running binding runtime tests on android, using Flutter's integration testing mechanism.

## How to run tests?

Generate runtime test files, by running the following in parent (jnigen) directory.

```bash
dart run tool/generate_runtime_tests.dart
```

This will generate integration_test/runtime_test.dart in this directory, along with other runtime tests for `jnigen`. This can be run with regular integration test mechanism.

```bash
flutter test integration_test/
```