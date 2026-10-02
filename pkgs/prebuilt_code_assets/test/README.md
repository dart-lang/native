# Testing `package:prebuilt_code_assets`

Run `dart test` to execute both the unit test suite ([`prebuilt_code_assets_test.dart`](prebuilt_code_assets_test.dart)) and the end-to-end integration test suite ([`integration_test.dart`](integration_test.dart)).

## What [`integration_test.dart`](integration_test.dart) verifies end-to-end

1. **Standalone Precompilation (`PrebuiltLibrary.buildStandalone`)**:
   - Compiles a real C source file (`math_lib.c` exporting `math_add` and `math_unused_multiply`) into both a dynamic library (`.so`/`.dylib`/`.dll`) and a static library (`.a`/`.lib`) using `CBuilder.library`.
2. **Release Hash Generation (`runRegenerateHashesCli`)**:
   - Runs `runRegenerateHashesCli` against the precompiled artifacts directory to generate `lib/hashes.dart` with SHA-256 checksums, and serves the binaries from a local `HttpServer` (simulating GitHub Releases without external network dependencies).
3. **`dart run` in `fetch` mode**:
   - Runs `dart run bin/main.dart` on a consumer package with `hook/build.dart` and `hook/link.dart`, verifying it downloads the dynamic library from the HTTP server, validates its SHA-256 digest, loads it via `@Native`, and outputs `Result: 42`.
4. **`dart build cli` with `@RecordUse` tree-shaking in `hook/link.dart`**:
   - Runs `dart build cli`, which triggers `hook/build.dart` (fetches the static `.a`/`.lib` and routes it to `ToLinkHook`) and `hook/link.dart` (runs `CLinker.library` with `LinkerOptions.treeshake` from `@RecordUse`).
   - Executes the compiled CLI binary (`Result: 42`) and inspects the bundled dynamic library via `DynamicLibrary.open` to verify:
     - `dylib.providesSymbol('math_add') == true` (used symbol kept)
     - `dylib.providesSymbol('math_unused_multiply') == false` (unused symbol stripped by the linker)
5. **`treeshake: auto` / `on` / `off` in `hook/link.dart`**:
   - Verifies `treeshake: off` bundles the prebuilt dynamic library directly without running the C linker (retaining both `math_add` and `math_unused_multiply`).
   - Serves an un-linkable static archive so `CLinker.library` fails in `hook/link.dart`, verifying that `treeshake: auto` (default) prints a warning and falls back to the prebuilt dynamic library (`Result: 42`), whereas `treeshake: on` fails the build.
6. **`hooks.user_defines` `buildMode: build` and `buildMode: local`**:
   - Verifies compiling from source in `hook/build.dart` (`buildMode: build`) and bundling a pre-existing dynamic library from disk (`buildMode: local` + `localPath`).

