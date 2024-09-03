## 0.7.4-wip

- Nothing yet.

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
