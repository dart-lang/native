## 0.10.0-wip

- Removed support for dry run (Flutter no long requires it).
- Various fixes to caching.
- **Breaking change** `BuildConfig.targetOS` is now only provided if
  `buildAssetTypes` contains the code asset.

## 0.9.0

- Also lock `BuildConfig` and `LinkConfig` `outputDirectoryShared` when invoking
  hooks to prevent concurrency issues with shared output caching.
- Fix test packages with RecordUse annotations
  [#1586](https://github.com/dart-lang/native/issues/1586).
- Update SDK constraint to 3.5.0+
- Rename the environment variables we use to communicate CCompilerConfig from
  Dart CI test runner to the `package:native_assets_builder` for testing the
  dart-lang/native repository to make it clear those are not intended to be used
  by end-users.
- Remove link-dry-run concept as it's unused by Flutter Tools & Dart SDK
- Bump `native_assets_cli` to `0.9.0`.
- **Breaking change**: Remove asset-type specific logic from `package:native_assets_builder`.
  Bundling tools have to now supply `supportedAssetTypes` and corresponding
  validation routines.
- **Breaking change**: The `NativeAssetsBuildRunner.link()` command will now
  produce a `LinkResult` containing all assets for the application (not just
  those that happened to have a linker). This removes the need for a bundling
  tool to combine parts of `BuildResult` and `LinkResult` and possibly checking
  consistency of the sum of those parts. Effectively this means: Any asset that
  doesn't have an explicit linker will get a NOP linker that emits as outputs
  it's inputs.
- **Breaking change** Removes knowledge about code & data assets from
  `package:native_assets_builder`. Users of this package can know hook into the
  build/link hook configuration that is used and e.g. initialize code
  configuration. Similarly users of this package now have to provide a callback
  to verify the consistency of the used hook configuration.

## 0.8.3

- Added a validation step on the output of the build and link hooks (both as a
  per package, and as in all the packages together).
- Fixed caching bug for link hooks
  [#1515](https://github.com/dart-lang/native/pull/1515).
- Bump `native_toolchain_c` to `0.5.4` and `native_assets_cli` to `0.8.0`.

## 0.8.2

- Fix some more cases of: `BuildConfig.dependencies` and
  `LinkConfig.dependencies` no longer have to specify Dart sources.
- `DataAsset` test projects report all assets from `assets/` dir and default the
  asset names to the path inside the package.
- Automatically locks build directories to prevent concurrency issues with
  multiple concurrent `dart` and or `flutter` invocations.
- Bump `package:native_assets_cli` to 0.7.3.

## 0.8.1

- `BuildRunner` now automatically invokes build hooks again if any of their Dart
  sources changed.
- Add more data asset test files.

## 0.8.0

- `BuildRunner.build` and `BuildRunner.buildDryRun` now have a required
  `linkingEnabled` parameter.

## 0.7.1

- Use `HookConfig.targetIosSdk` and `HookConfig.targetMacosSdk` optional
  values, and add examples to fail builds based on this.
- Add data asset test project.

## 0.7.0

- Add support for `hook/link.dart` including dry runs.
  Link hooks that do not have assets for link sent to them, are not run.
  Link hooks are not ordered.
- Fix test.
- Bump `package:native_assets_cli` to 0.6.0.
- Copy `resources.json` to the build directory.

## 0.6.0

- **Breaking change** Completely rewritten API in `native_assets_cli`.
- **Breaking change** Move `build.dart` to `hook/build.dart`.
  https://github.com/dart-lang/native/issues/823
  (Backwards compatibility, fallback to toplevel `build.dart`.)
- Bump `package:native_assets_cli` to 0.5.0.

## 0.5.0

- **Breaking change**: Hide implementation of `KernelAssets`.

## 0.4.0

- **Breaking change**: Split out the `KernelAsset`s from normal `Asset`s.

## 0.3.2

- Reintroduce `AssetRelativePath`, it's used in `dart build`.

## 0.3.1

- Add support for `runPackageName` to avoid native assets for packages that
  the root package depends on but the package being run doesn't.
- Bump `package:native_assets_cli` to 0.4.1.
- Moved test projects from `test/data/` to `test_data/`.

## 0.3.0

- Bump `package:native_assets_cli` to 0.3.0
  ([#142](https://github.com/dart-lang/native/issues/142)).

## 0.2.3

- Quicker build planning for 0 or 1 packages with native assets
  ([#128](https://github.com/dart-lang/native/issues/128)).

## 0.2.2

- Take a `PackageLayout` argument for `build` and `dryRun`
  ([flutter#134427](https://github.com/flutter/flutter/issues/134427)).

## 0.2.1

- Provide a `PackageLayout` constructor for already parsed `PackageConfig`
  ([flutter#134427](https://github.com/flutter/flutter/issues/134427)).

## 0.2.0

- **Breaking change** `NativeAssetsBuildRunner`s methods now return an object
  ([#105](https://github.com/dart-lang/native/issues/105)).
- **Breaking change** `NativeAssetsBuildRunner`s methods now return value now
  contain a success bool instead of throwing
  ([#106](https://github.com/dart-lang/native/issues/106)). Error messages are
  streamed to the logger.
- Use an `out/` sub directory for building native assets
  ([#98](https://github.com/dart-lang/native/issues/98)).
- Check asset ids on having having a package uri with the owning package
  ([#96](https://github.com/dart-lang/native/issues/96)).
- `NativeAssetsBuildRunner` now supports multiple calls
  ([#102](https://github.com/dart-lang/native/issues/102)).

## 0.1.0

- Initial version.
