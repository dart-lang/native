## Generating bindings for Apple APIs

It can be tricky to locate header files containing Apple's ObjC frameworks, and
the paths can vary between computers depending on which version of Xcode you are
using and where it is installed. So FFIgen provides the following variable
substitutions that can be used in the `headers.entry-points` list:

- `$XCODE`: Replaced with the result of `xcode-select -p`, which is the
  directory where Xcode's APIs are installed.
- `$IOS_SDK`: Replaced with `xcrun --show-sdk-path --sdk iphoneos`, which is the
  directory within `$XCODE` where the iOS SDK is installed.
- `$MACOS_SDK`: Replaced with `xcrun --show-sdk-path --sdk macosx`, which is the
  directory within `$XCODE` where the macOS SDK is installed.

For example:

```Yaml
headers:
  entry-points:
    - '$MACOS_SDK/System/Library/Frameworks/Foundation.framework/Headers/NSDate.h'
```

In the Dart API you can use these getters:
`xcodePath`, `iosSdkPath`, and `macSdkPath`.
