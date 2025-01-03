An example of a library depending on prebuilt assets which are downloaded in
the build hook.

## Usage

Run tests with `dart --enable-experiment=native-assets test`.

## Code organization

A typical layout of a package which downloads assets:

* `hook/build.dart` downloads the prebuilt assets.
* `lib/` contains Dart code which uses the assets.
* `tool/build.dart` prebuilts assets and is exercised from the GitHub CI.
