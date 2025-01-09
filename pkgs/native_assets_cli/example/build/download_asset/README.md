An example of a library depending on prebuilt assets which are downloaded in
the build hook.

## Usage

Run tests with `dart --enable-experiment=native-assets test`.

## Code organization

A typical layout of a package which downloads assets:

* `tool/build.dart` prebuilts assets and is exercised from a GitHub workflow.
* A [github workflow](../../../../../.github/workflows/native.yaml) that builds assets.
* `hook/build.dart` downloads the prebuilt assets.
* `lib/` contains Dart code which uses the assets.
