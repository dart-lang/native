## 0.3.2

- Fixed an issue where `Depenendencies.dependencies` could not be
  modified when expected to.
  **Note:** Avoid modifying `Dependencies.dependencies` directly,
  the property will likely return an `Iterable` in a future release.

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
