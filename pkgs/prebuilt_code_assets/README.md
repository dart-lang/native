# `package:prebuilt_code_assets`

Shared build and link hook infrastructure for Dart packages that distribute prebuilt native code assets (via GitHub Releases or bundled `prebuilt/` directories), support compiling from source through a toolchain-agnostic `buildFromSource` callback (e.g. `CBuilder` from `package:native_toolchain_c`, CMake, or Cargo), and tree-shake static libraries in `hook/link.dart` via `@RecordUse`.

Modeled after `CLibrary` in `package:native_toolchain_c`, a single `PrebuiltLibrary` specification is defined once and shared across `hook/build.dart`, `hook/link.dart`, `tool/precompile_binaries.dart`, and `tool/regenerate_hashes.dart`.

## Features

- **Unified `PrebuiltLibrary` specification**:
  - `library.build(input: input, output: output)` for `hook/build.dart`.
  - `library.link(input: input, output: output)` for `hook/link.dart`.
  - `library.buildStandalone(...)` (via `BuildInputBuilder`) for standalone CI scripts.
- **Standardized build modes** (`buildMode` under `hooks.user_defines.<package_name>`):
  - `fetch` (default): Uses a pub-bundled `prebuilt/` binary if present, or downloads the prebuilt binary, verifies its SHA-256 digest, and caches it in `outputDirectoryShared` (in an ABI-specific subdirectory preserving the canonical OS library filename for iOS/macOS XCFrameworks). Downloads are streamed, retried on transient failures, and written atomically. Optionally falls back to `buildFromSource` if no binary is available.
  - `build` (alias `checkout`): Compiles from source using `buildFromSource` (optionally from `checkoutPath`).
  - `local`: Bundles a pre-existing dynamic library from `localPath`.
- **Tree-shaking link hook** (`treeshake` under `hooks.user_defines.<package_name>`):
  - Resolves used symbols via `usedSymbols`, such as `SymbolsResolvers.fromRecordUseMapping` (`ffigen`) or `SymbolsResolvers.fromMethodPrefix` (e.g. Diplomat). Without `usedSymbols`, the library is never tree-shaken, and the build hook bundles the dynamic library directly.
  - `auto` (default): Tree-shakes when possible. If no static library is released for a target, or if linking fails in `fetch` mode (e.g. no C toolchain for the target), prints a warning and bundles the prebuilt dynamic library instead.
  - `on`: Always tree-shakes, and fails the build if that is not possible.
  - `off`: Never tree-shakes; bundles the dynamic library directly without running the C linker.
  - If the application uses none of the library's functions, the link hook bundles no library at all.
  - If record use is disabled, it is unknown which functions the application uses, so nothing can be tree-shaken. Then `fetch` mode bundles the prebuilt dynamic library. When building from source, the link hook links the static library keeping all functions, except on Windows, where a DLL only exports the functions it lists; that fails the build (use `treeshake: off` instead).
  - On Windows, `package:native_toolchain_c` only exports the used functions that the `.lib` defines.
  - On Windows, don't mark functions with `__declspec(dllexport)` when compiling the static library: the linker then exports, and so keeps, every such function in each object file it links, even unused ones. The `.def` file already determines the exports.
  - Any other assets routed to the package's link hook are forwarded unchanged.
- **Maintainer CLI runners** (`package:prebuilt_code_assets/tools.dart`):
  - `runPrecompileBinariesCli` for `tool/precompile_binaries.dart`.
  - `runRegenerateHashesCli` for `tool/regenerate_hashes.dart` (supports both local artifact directories and remote release URLs, and refuses to write an incomplete manifest when downloads fail).

## Usage

### 1. Define your `PrebuiltLibrary` (`lib/src/hook_helpers/library.dart`)

```dart
import 'package:prebuilt_code_assets/prebuilt_code_assets.dart';
import 'package:record_use/record_use.dart' as record_use;

import '../bindings/record_use_mapping.g.dart';
import 'hashes.dart';

final myLibrary = PrebuiltLibrary(
  name: 'my_lib',
  assetName: 'my_package.dart',
  releaseConfig: PrebuiltReleaseConfig.github(
    owner: 'my-org',
    repo: 'my_package',
    version: version,
    fileHashes: fileHashes,
    libraryName: 'my_lib',
  ),
  buildFromSource: (input, output, {required static, checkoutPath}) async {
    // Compile with your toolchain (e.g. `CBuilder`, CMake, or Cargo), add the
    // sources you read to `output.dependencies`, and return the Uri of the
    // built static (if `static`) or dynamic library.
  },
  usedSymbols: SymbolsResolvers.fromRecordUseMapping(
    const record_use.Library('package:my_package/src/bindings/bindings.g.dart'),
    recordUseMapping,
  ),
);
```

For release layouts other than `<repo>-<target>-<libraryFileName>`, pass a custom `resolveAssetName` to `PrebuiltReleaseConfig.github`, or use the `PrebuiltReleaseConfig` constructor directly.

### 2. Wire up `hook/build.dart` and `hook/link.dart`

```dart
// hook/build.dart
import 'package:hooks/hooks.dart';
import 'package:my_package/src/hook_helpers/library.dart';

Future<void> main(List<String> args) async {
  await build(args, (input, output) async {
    await myLibrary.build(input: input, output: output);
  });
}
```

```dart
// hook/link.dart
import 'package:hooks/hooks.dart';
import 'package:my_package/src/hook_helpers/library.dart';

Future<void> main(List<String> args) async {
  await link(args, (input, output) async {
    await myLibrary.link(input: input, output: output);
  });
}
```

Both methods accept an optional `Logger`; by default messages are printed to the hook's stdout/stderr.

### 3. Configuring `user_defines` in `pubspec.yaml`

Consumers of your package configure how the native library is obtained and whether it is tree-shaken under `hooks.user_defines.<package_name>` in their workspace or application `pubspec.yaml`:

```yaml
hooks:
  user_defines:
    my_package:
      # 'fetch' (default), 'build' (alias 'checkout'), or 'local'
      buildMode: fetch
      # 'auto' (default), 'on', or 'off'
      treeshake: auto
      # Path to a local source checkout (used when buildMode is 'build')
      # checkoutPath: ../path/to/checkout
      # Path to a pre-existing dynamic library on disk (required when buildMode is 'local')
      # localPath: /absolute/or/relative/path/to/libmy_lib.so
```

| Key | Type | Description |
| :--- | :--- | :--- |
| `buildMode` | `String` | `'fetch'` (default: use bundled `prebuilt/` or download from release URL), `'build'` / `'checkout'` (compile from source), or `'local'` (use a binary at `localPath`). |
| `treeshake` | `String` or `bool` | `'auto'` (default), `'on'` / `true`, or `'off'` / `false`. See [Features](#features). |
| `local_build` | `bool` | Shorthand used by `dart-lang/native` examples: `local_build: true` means `buildMode: build`. Ignored if `buildMode` is set. |
| `checkoutPath` | `String` (path) | Optional path to a local source directory when `buildMode` is `'build'`. |
| `localPath` | `String` (path) | Path to a pre-built dynamic library file when `buildMode` is `'local'`. |

Relative paths are resolved against the `pubspec.yaml` that defines them. Unknown values fail the build with an explanation (set `strictBuildOptions: false` on `PrebuiltLibrary` to fall back to the defaults instead).
