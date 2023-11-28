## 0.3.1-wip

- Add support for `runPackageName` to avoid native assets for packages that
  the root package depends on but the package being run doesn't.

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
