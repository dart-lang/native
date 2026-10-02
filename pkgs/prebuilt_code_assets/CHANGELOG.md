## 0.2.0-wip

- Moved to [dart-lang/native](https://github.com/dart-lang/native/tree/main/pkgs/prebuilt_code_assets).
- **Breaking:** Require Dart 3.13, the first stable SDK in which `dart build`
  records `@RecordUse` usages by default, which tree-shaking relies on.
- **Breaking:** Removed the Rust-specific APIs `CargoSourceBuilder`,
  `asRustTarget`, `asRustTargetForConfig`, and
  `PrebuiltReleaseConfig.rustTargets`. They encoded one project's toolchain
  choices (pinned nightly, `-Zbuild-std`, `no_std` targets, `rustup`
  side effects) and release layout. Rust packages should implement
  `buildFromSource` and a custom `resolveAssetName` themselves.
- **Breaking:** Renamed `BuildMode` to `NativeBuildMode` so it no longer clashes
  with `BuildMode` from `package:native_toolchain_c`. Removed the
  `BuildModeEnum` alias, the `BuildMode.checkout` value (the user-define value
  `checkout` is still accepted as an alias for `build`), and
  `BuildOptions.isSourceBuild`.
- **Breaking:** Removed `envVarPrefix` and the `<PREFIX>_*` environment
  variable overrides. `hooks_runner` only passes an allowlist of environment
  variables to hooks, so these never took effect in `dart` or `flutter`
  builds.
- **Breaking:** `strictBuildOptions` (and `BuildOptions.fromDefines(strict:)`)
  now defaults to `true`. User-defines of the wrong type always throw a
  `BuildError` instead of a `TypeError`.
- **Breaking:** `fetchPrebuiltLibrary`'s `fallbackBuildModeName` is replaced by
  `canBuildFromSource`; it also accepts `logger`, timeouts, and `maxAttempts`.
- **Breaking:** Removed `package:prebuilt_code_assets/testing.dart` (ELF
  helpers) and the COFF archive helpers.
- **Breaking:** `runPrecompileBinariesCli` throws a `UsageException`
  (re-exported from `tools.dart`) instead of calling `exit`, and requires
  `--ios-sdk` for iOS so asset names match what `fetch` requests.
- **Breaking:** `runRegenerateHashesCli` no longer writes a license header by
  default, fails without writing files if any asset can't be hashed (other
  than missing files / HTTP 404; opt out with `failOnError: false`), and
  requires `versionFilePath` to be in the same directory as `hashesFilePath`.
- **Breaking:** `PrebuiltLibrary.libraries` and `PrebuiltLibrary.frameworks`
  are now both callbacks taking the target `CodeConfig` (instead of an `OS`
  and a fixed list, respectively), so frameworks can differ between macOS and
  iOS and both can depend on the architecture or SDK. A `null` `frameworks`
  now keeps the `CLinker` default (`Foundation`) instead of linking no
  frameworks; pass `(_) => const []` for the previous behavior.
- **Breaking:** On Windows, without recorded uses, `link` exports
  `allKnownSymbols`. If that is `null` too, `link` bundles the prebuilt dynamic
  library in the `fetch` build mode and throws a `BuildError` otherwise,
  instead of exporting every symbol of the static library.
- Fixed `build` routing a static library to the link hook when linking is
  disabled but the link mode preference is static, which fails hook output
  validation.
- On Windows, `link` uses `LinkerOptions.treeshake` like on other platforms,
  instead of reading the symbols of the static library itself.
  `package:native_toolchain_c` 0.19.6, which this requires, only exports the
  symbols that the static library defines, and supports thousands of them.
- Fixed `link` dropping other assets routed to the package's link hook, and
  matching assets whose ID merely ends with `assetName`.
- Fixed the default logger mutating the global root logger and adding a new
  listener on every `link` call. `build` now also accepts a `Logger`.
- In `fetch` mode with `treeshake: auto`, `build` now bundles the prebuilt
  dynamic library (with a warning) when no static library is released for the
  target, instead of failing or building from source.
- With `treeshake: off`, `link` never runs the C linker.
- Downloads are streamed to disk while hashing, written atomically to the
  shared cache, time out, and are retried on transient failures.
- Bundled `prebuilt/` binaries are verified against `fileHashes` when a hash is
  registered for them.
- `buildStandalone` accepts `packageName` and only sets up the macOS code config
  for macOS targets.
- Added CI on Linux, macOS, and Windows, and an example.

## 0.1.2

- Removed `PrebuiltLibrary.fromCLibrary` and `native_toolchain_c` re-exports to keep the `PrebuiltLibrary` API surface minimal.

## 0.1.1

- Added `PrebuiltLibrary.fromCLibrary` to reuse `CLibrary` metadata and compiler/linker configuration from `package:native_toolchain_c` without duplication.
- Re-exported `CLibrary`, `Language`, and `OptimizationLevel` from `package:prebuilt_code_assets/prebuilt_code_assets.dart`.
- Documented `hooks.user_defines.<package_name>` keys (`buildMode`, `local_build`, `checkoutPath`, `localPath`) and environment variable overrides in `README.md`.

## 0.1.0

- Initial version:
  - `PrebuiltLibrary` specification for `hook/build.dart`, `hook/link.dart`, and standalone `BuildInputBuilder` builds.
  - `BuildOptions` and `BuildMode` (`fetch`, `build`, `checkout`, `local`) parsing for `hooks.user_defines`.
  - Prebuilt binary fetching with `outputDirectoryShared` ABI-subdirectory caching, pure-Dart SHA-256 verification, and bundled `prebuilt/` directory support.
  - Link-hook tree-shaking via `@RecordUse` (`SymbolsResolvers`), Windows COFF `.lib` symbol parsing, `.def` module-definition fallback, and automatic fallback to prebuilt dynamic libraries when linking fails.
  - Maintainer CLI runners (`runPrecompileBinariesCli`, `runRegenerateHashesCli`) and ELF `.dynsym` test helpers.
