# Generating bindings for Apple APIs

It can be tricky to locate header files containing Apple's Objective-C frameworks, and
the paths can vary between computers depending on which version of Xcode you are
using and where it is installed. FFIgen provides helper getters that can be used
when configuring `Input.entryPoints`:

- `xcodeUri` / `xcodePath`: The directory where Xcode's APIs are installed
  (resolved via `xcode-select -p`).
- `iosSdkUri` / `iosSdkPath`: The directory within Xcode where the iOS SDK is
  installed (resolved via `xcrun --show-sdk-path --sdk iphoneos`).
- `macSdkUri` / `macSdkPath`: The directory within Xcode where the macOS SDK is
  installed (resolved via `xcrun --show-sdk-path --sdk macosx`).

For example:

```dart
final generator = FfiGenerator(
  input: Input(
    entryPoints: [
      macSdkUri.resolve(
        'System/Library/Frameworks/Foundation.framework/Headers/NSDate.h',
      ),
    ],
  ),
  ...
);
```
