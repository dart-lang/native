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
