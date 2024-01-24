Build Hook Specification
========================

**DISCLAIMER:** This is really just a native attempt, at writing a specification.


## Version 1: Currently implemented behind `--enable-experiment=native-assets`


### Concepts


#### Asset
A file that is identified by an `assetId`. There may be multiple files with the
same `assetId` with different characteristics such as `target` or `link_mode`.

#### AssetId
An asset must have an `assetId`. Dart code that uses an asset, references the
asset using the `assetId`.

A package MUST prefix all assetIds it defines with: `package:<package>/`, this
ensures assets don't conflict between packages.

Conventionally, an asset referenced from `lib/src/foo.dart` in `package:foo`
has `assetId = 'package:foo/src/foo.dart'`.

#### Target

A target specifies operating system and architecture.

List of `platform` and `architecture` tuples supported by the
Dart and Flutter SDKs to be specified below:
 * `linux_x64`
 * TODO: enumerate full list of supported platform/architecture tuples.

**Remark:** It may appear confusing that `link_mode` is not part of the target
(if so, that's probably because it is confusing).


### `build.dart`
A package with native assets MUST define a `build.dart` file which accepts
a `--config` option as follows:

```console
$ dart build.dart --config <build_config.yaml>
```

The `--config` option specifies location of the `build_config.yaml` file.

The `build.dart` file MUST:
 * Read the `build_config.yaml` file,
 * Build assets using configuration from `build_config.yaml`.
   * If `dry_run: true` in `build_config.yaml`, then this may be skipped.
 * Write assets into `out_dir` from `build_config.yaml`.
   * If `dry_run: true` in `build_config.yaml`, then this may be skipped.
   * Filename are unrelated to `assetId`.
   * Arbitrary file names are fine, `build_output.yaml` will map `assetId` to files. 
   * MUST avoid file name `build_output.yaml` (yes, this is poor design)
 * Write `build_output.yaml` into `out_dir` (from `build_config.yaml`).
   * This maps `assetId` to assets previous written in `out_dir`.
   * There may be multiple assets for a given `assetId` depending on
     characteristics like `target`, `link_mode`, etc.
   * If `dry_run: true` in `build_config.yaml`, the list of assets that would be
     generated must this be enumerated. Mapping `assetId`s to non-existing files
     is expected.


### `build_config.yaml`
Configuration file passed to `build.dart` as the `--config` option.

```yaml
# Build in dry-run mode.
#
# Running in dry-run mode `<out_dir>/build_output.yaml` must be written, but
# the files it references need not exist.
dry_run: true | false
# Build Mode.
#
# A hint `build.dart` can use to determined which optimizations to enable and
# whether or not to include debug symbols in the format relevant for the asset.
build_mode: release | debug
# Unspecified
dependency_metadata: {}
# Preferred link mode
link_mode_preference: dynamic | static | prefer-dynamic | prefer-static
# Path to output directory where assets should be placed.
#
# This is also where `build_output.yaml` should be written.
#
# Remark: Avoid using the name "build_output.yaml" for an asset file, this is
#         forbidden.
out_dir: <path/to/out_dir/>
# Name of the package that contains the `build.dart`
#
# Remark: This is entirely redundant since this is a config file specified to
# `build.dart`, and the author of `build.dart` probably knows the name of the
# package they are writing.
package_name: my_package_with_native_assets
# Path to root folder for the package that contains `build.dart`.
#
# This is useful if `build.dart` wishes to find source code files embedded in
# its own package and compile them to an asset.
package_root: $PUB_CACHE/hosted/.../my_package_with_native_assets/
# Target architecture
#
# Combined with `target_os` this specifies the "target" for which assets
# should be built
target_architecture: x64
# Target operating system
#
# Combined with `target_architecture` this specifies the "target" for which
# assets should be built.
#
# Remark: If this appears confusing, that's because it is.
target_os: linux
# Version of this file.
version: 1.0.0
```

### `build_output.yaml`
Mapping from `assetId`s to files created by `build.dart`.

```yaml
timestamp: <date-time>
assets:
  - id: <assetId>
    link_mode: dynamic | static | prefer-dynamic | prefer-static
    path:
      path_type: absolute | relative
      uri: <out_dir/arbitrary_filename.whatever>
    target: <target>
  ...
dependencies:
  - <path/to/source-file.c>
  ...
metadata: {}
version: 1.0.0
```


### `.dart_tool/native_assets.yaml`

This file is internal to the Dart SDK and Flutter SDK.
It produced by `native_asset_builder` (as embedded in the SDKs).
For each `target` it maps from `assetId` to `url`
(with `urlKind` indicating if it's a relative or absolute path).

```yaml
format-version: [1, 0, 0]
native-assets:
  <target>:
    <assetId>: [<urlKind>, <url>]
  ...
```

This file is used by the embedded SDK to resolve `assetId`s when running in
development mode or build a deployable application (or standalone executable).




## Version 2: Proposal for a next iteration.

### Concepts

#### Asset
#### AssetId
#### ...



