An example of a library that builds dynamic libraries across multiple GitHub
Actions runners, pulls them all into a single GitHub Actions job (under
`prebuilt/`), and runs `dart pub publish` to bundle the prebuilt dynamic
libraries directly inside the published pub package.

## Usage

Run tests with `dart test`.

When `prebuilt/<target_dylib>` is present (as it is in the published pub package
or after running `dart tool/build.dart`), `hook/build.dart` emits a `CodeAsset`
pointing directly to the prebuilt library inside `input.packageRoot`.
If the prebuilt asset is not present (e.g., during local development before
prebuilding) or when `local_build: true` is set, `hook/build.dart` falls back
to building from source.

## Code organization

* `tool/build.dart` prebuilds assets into `prebuilt/` and is exercised from a
  GitHub workflow.
* A [GitHub workflow](../../../../../.github/workflows/package_prebuilt_assets_example.yaml)
  that builds assets across a matrix of runners, downloads them all into
  `prebuilt/` in a single job, and runs `dart pub publish`.
* `.gitignore` ignores `prebuilt/` so binaries are not committed to source
  control, while `.pubignore` overrides `.gitignore` for `dart pub publish` so
  that `prebuilt/` is included in the published package archive.
* `hook/build.dart` bundles the prebuilt asset from `prebuilt/` (or falls back
  to building from source).
* `lib/` contains Dart code which uses the assets.
