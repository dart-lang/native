## 0.23.2

- Add `LIBCLANG_PATH` to the environment variables allowlist.

## 0.23.1

- Change the length of the checksum used for `outputDirectory` to 10 hexadecimal
  characters to avoid running out of path length on Windows.

## 0.23.0

- **Breaking change**: Replaced `NativeAssetsBuildRunner.hookEnvironmentVariablesFilter`
  with `NativeAssetsBuildRunner.includeHookEnvironmentVariable` to account for
  environment variables that start with a particular prefix (i.e., `NIX_`).

## 0.22.1

* Fix caches not being invalidated on (1) user-defines changing, (2) metadata
  changing, and (3) assets sent to link hooks.
  

## 0.22.0

* Bump `package:hooks` to 0.20.0.
* Enable passing metadata from link hooks of a package to the link hooks in 
  depending packages, by fixing the link hook execution order. This brings an
  order in which the link hooks are run - reverse to the build hook run order.
  Starting at the application link hook, then it's dependencies, and so on. This
  enables us to pass information from on link hook to another as
  `MetadataAsset`s - but also means that now link hooks must be invoked,
  regardless of whether assets are sent to the from a build hook.

## 0.21.0

* Add `includeDevDependencies` param to `BuildLayout` to enable building the
  assets for dev dependencies of the `runPackage`.

## 0.20.2

* Add `dart:developer` `TimelineEvent`s to enable performance tracing for
  hook invocations.

## 0.20.1

* Bump the SDK constraint to at least the one from `package:hooks` to fix
  dartdoc generation on https://pub.dev.

## 0.20.0

- **Breaking change** Refactored error handling to use a `Result` type for more
  explicit success/failure states.
- Remove `package_graph.json` fallback.

## 0.19.0

- Renamed package from `native_assets_builder` to `hooks_runner`.
- Depend on `package:code_assets`, `package:data_assets`, and `package:hooks`
  0.19.0. (`package:native_assets_cli` was split up into these packages.)

## 0.18.0

- Bump `package:native_assets_cli` to 0.18.0.

## 0.17.0

- Bump `package:native_assets_cli` to 0.17.0.

## 0.16.0

- Pass in path to pubspec (to read user-defines) in this package rather than in
  the SDKs using this package.
- Bump `package:native_assets_cli` to 0.16.0.

## 0.15.0

- Bump `package:native_assets_cli` to 0.16.0.

## 0.14.0

- Bump `package:native_assets_cli` to 0.14.0.
- Route assets from build hook to build hook with `ToBuild` `Routing`.
- Support user-defines.

## 0.13.0

- Bump `package:native_assets_cli` to 0.13.0 and required fixes.
- Stop reading `HookInput` and `HookOutput` `version`.

## 0.12.0

- Organized the `ProtocolExtension`s in a class.
- Bump `package:native_assets_cli` to 0.12.0.

## 0.11.1

- Don't recompile hooks on `package_config.json` having an updated timestamp.

## 0.11.0

- **Breaking change** Complete overhaul of the use of `NativeAssetsBuildRunner`
  to support pub workspaces
  ([#1905](https://github.com/dart-lang/native/issues/1905)).
- Bump `package:native_assets_cli` to 0.11.0.

## 0.10.2

- Export types (fix for 0.10.1).

## 0.10.1

- Pass in the environment for hook invocations.

## 0.10.0

- Removed support for dry run (Flutter no long requires it).
- Various fixes to caching.
- **Breaking change** `BuildConfig.targetOS` is now only provided if
  `buildAssetTypes` contains the code asset.
- **Breaking change** `NativeAssetsBuildRunner` and `PackageLayout` now take a
  `FileSystem` from `package:file/file.dart`s.
- Bump `package:native_assets_cli` to 0.10.0.

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
