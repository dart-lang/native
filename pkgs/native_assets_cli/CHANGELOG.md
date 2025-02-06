## 0.11.0-wip

- **Breaking change** Complete overhaul of the API used in build and link hooks.
  The `BuildConfig` is now split in `BuildInput` and `BuildConfig`. The input is
  everything passed in to the hook. The config (a part of the input) is what
  shouldn't change on subsequent invocations of the same flutter or dart command
  for the same target. The `outputDirectory` is the same if the config is the
  same.
- **Breaking change** The `output.json` is now part of `BuildInput`.

## 0.10.0

- **Breaking change** The library import paths changed to be per asset type.
  (This enables extensibility with custom asset types.)
- **Breaking change**: Rename `supportedAssetTypes` to `buildAssetTypes`. Hooks
  should no longer fail. Instead, the code should fail at runtime if an asset is
  missing. This enables (1) code to run if an asset is missing but that code is
  not invoked at runtime, and (2) doing fallback implementations in Dart if an
  asset is missing.
- **Breaking change** Move `BuildMode` to `package:native_toolchain_c`. This way
  it can be controlled in the build hook together with the `OptimizationLevel`.
  Most likely, every package should ship with `release`. `BuildMode.debug`
  should only be used while developing the package locally.
- **Breaking change** Move `HookConfig.targetOS` to `CodeConfig`. `DataAsset`s
  and other asset types should not depend on OS for now.
- **Breaking change**: Change the behavior of `testBuildHook` and
  `testCodeBuildHook`; instead of defining tests, these methods should now be
  called from within tests.
- Move the `package:test` dependency from a regular dependency (exported to
  calling packages) to a dev_dependency.

## 0.9.0

- Add `BuildConfig` and `LinkConfig` `outputDirectoryShared`.
- Remove `package:native_assets_cli/locking.dart` with `runUnderDirectoryLock`.
  Hook writers should not use this, the `native_assets_builder` does this.
- Fix example packages with RecordUse annotations
  [#1586](https://github.com/dart-lang/native/issues/1586).
- Remove v1.0 / v1.1 related serialization
- Update SDK constraint to 3.5.0+
- Remove (deprecated) support for accepting yaml as config
- Remove usage of `package:cli_config` and `package:args`: it minimizes
  dependencies and it simplifies logic any hook has to do (as it no longer has
  to look into environment variables, arguments and json file, determine which
  has presence over other, etc)
- Use `DART_HOOK_TESTING` prefix for environment variables used for testing on
  Dart CI
- No longer try to resolve uris encoded in `config.json` against any base uri.
  The `hook/{build,link}.dart` invoker has to ensure the uris it encodes can be
  opened as-is (i.e. without resolving against any base uri)
- **Breaking change** Moved some methods to be extension methods.
- Some classes in the `BuildConfig` and `BuildOutput` now expose `fromJson` and
  `toJson`.
- **Breaking change** Removed `Asset` class, removed `{Build,Link}Output.assets*`.
   Hook writers should now use e.g. `output.dataAssets.add(DataAsset(...))`
   instead of `output.addAsset(DataAsset(...))`.
- **Breaking change** Introduce builder classes that construct hook configs and
  hook outputs.

## 0.8.0

- Add URI for the recorded usages file to the `LinkConfig`.
- Added a validation step in the `build` and `link` methods.

## 0.7.3

- Fix some more cases of: `BuildConfig.dependencies` and
  `LinkConfig.dependencies` no longer have to specify Dart sources.
- `DataAsset` examples report all assets from `assets/` dir and default the
  asset names to the path inside the package.
- Add `package:native_assets_cli/test.dart` with `testBuildHook` helper method
  for testing build hooks.
- Add `package:native_assets_cli/locking.dart` with `runUnderDirectoryLock`.

## 0.7.2

- Deprecate metadata concept.

## 0.7.1

- `BuildConfig.dependencies` and `LinkConfig.dependencies` no longer have to
  specify Dart sources.

## 0.7.0

- `BuildConfig` constructors now have a required `linkingEnabled` parameter.

## 0.6.1

- Introduce `Builder` and `Linker` interface.
- Copy `resources.json` to the build directory.
- Introduce `HookConfig.targetIosSdk` and `HookConfig.targetMacosSdk` optional
  values.

## 0.6.0

- Add support for `hook/link.dart`.

## 0.5.4

- Update documentation about providing `NativeCodeAsset.file` in dry runs.

## 0.5.3

- Fix V1_0_0 dry run backwards compatibility.
  https://github.com/dart-lang/native/issues/1053

## 0.5.2

- Fix test.

## 0.5.1

- Update documentation about providing `NativeCodeAsset.file` in dry runs.
  https://github.com/dart-lang/native/issues/1049

## 0.5.0

- **Breaking change** Completely rewritten API.
  https://github.com/dart-lang/native/pull/946
- **Breaking change** Move `build.dart` to `hook/build.dart`.
  https://github.com/dart-lang/native/issues/823
- **Breaking change** Use JSON instead of YAML in the protocol.
  https://github.com/dart-lang/native/issues/991
- Bump examples dependencies to path dependencies.

## 0.4.2

- Fix dartdoc generation. Hide the implementation details.

## 0.4.1

- **Breaking change** Removed all code not used in `build.dart` scripts out of
  the public API.

## 0.4.0

- Added [example/use_dart_api/](example/use_dart_api/) detailing how to use
  `dart_api_dl.h` from the Dart SDK in native code.
- **Breaking change** Moved code not used in `build.dart` to
  `package:native_assets_builder`.

## 0.3.2

- Fixed an issue where `Depenendencies.dependencies` could not be
  modified when expected to.

## 0.3.1

- Added `Target.androidRiscv64`.

## 0.3.0

- **Breaking change** Add required `BuildConfig.packageName`
  ([#142](https://github.com/dart-lang/native/issues/142)).

## 0.2.0

- **Breaking change** Rename `Asset.name` to `Asset.id`
  ([#100](https://github.com/dart-lang/native/issues/100)).
- Added topics.
- Fixed metadata example.
- Throws `FormatException`s instead of `TypeError`s when failing to parse Yaml
  ([#109](https://github.com/dart-lang/native/issues/109)).

## 0.1.0

- Initial version.
