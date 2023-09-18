## 0.2.5

- Explicitly tell linker to create position dependent or position independent executable
  ([#113](https://github.com/dart-lang/native/issues/133)).

## 0.2.4

- Added `includes` for specifying include directories.
- Added `flags` for specifying arbitrary compiler flags.
- Added `std` for specifying a language standard.
- Added `language` for selecting the language (`c` and `cpp`) to compile source files as.
- Added `cppLinkStdLib` for specifying the C++ standard library to link against.

## 0.2.3

- Fix MSVC tool resolution inside (x86) folder
  ([#123](https://github.com/dart-lang/native/issues/123)).

## 0.2.2

- Generate position independent code for libraries by default and add
  `pic` option to control this behavior.

## 0.2.1

- Added `defines` for specifying custom defines.
- Added `buildModeDefine` to toggle define for current build mode.
- Added `ndebugDefine` to toggle define of `NDEBUG` for non-debug builds.

## 0.2.0

- **Breaking change** Rename `assetName` to `assetId`
  ([#100](https://github.com/dart-lang/native/issues/100)).
- Added topics.

## 0.1.0

- Initial version.
