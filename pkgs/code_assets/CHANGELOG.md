## 1.3.0

- Validate that a bundled dynamic library was built for the target
  architecture by reading its ELF, Mach-O (including fat), or PE header. A
  recognized library built for the wrong architecture or in the wrong format
  for the target OS is a validation error; unrecognized files only produce a
  warning on the new optional `logger` of `CodeAssetExtension`,
  `validateCodeAssetBuildOutput`, and `validateCodeAssetLinkOutput`, with a
  pointer to file an issue.

## 1.2.1

- Avoid throwing a null-assertion error/exception when `input.config.code` is
  accessed but `input.config.buildCodeAssets` is `false`. Instead, throw a
  clear and descriptive `StateError`.

## 1.2.0

- Added an optional `sanitizer` parameter to `CodeConfig` and `CodeAssetExtension` supporting `asan`, `msan`, and `tsan`.

## 1.1.0

- Bumped dependency on `package:hooks` to `^2.0.0` and implemented the new `outputFiles` protocol extension method to track generated files for cache invalidation, correctly omitting non-local assets like system libraries.

## 1.0.0

- Stable release.

## 0.19.10

- Document `input.packageRoot` in more places.
- Document `CodeAsset.id` package namespacing.

## 0.19.9

- Document that asset file paths must be absolute.

## 0.19.8

- Polished README.md, Dartdocs, and examples.

## 0.19.7

- Bump examples to use `package:ffigen` 20.0.0-dev.0.

## 0.19.6

- Added a library comment detailing how to use the package.
- Fixed duplicate asset id detection with assets coming from both build and
  link hooks.

## 0.19.5

- Bump `package:hooks` to 0.20.0.

## 0.19.4

* Add doc comments to all public members.

## 0.19.3

* Mark this package as in preview.

## 0.19.1

* Bump the SDK constraint to at least the one from `package:hooks` to fix
  dartdoc generation on https://pub.dev.

## 0.19.0

- Split up `package:native_assets_cli` in `package:hooks`,
  `package:code_assets`, and `package:data_assets`.

## 0.1.0

- Initial version.
