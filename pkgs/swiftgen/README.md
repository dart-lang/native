# Swiftgen

An experimental tool for generating bindings that allow interop between Dart and
Swift code.

## Detecting Classes and Modules in Binaries

When generating bindings for Swift code, `package:objective_c` looks up classes
in the Objective-C runtime using their fully qualified name: `<module>.<ClassName>`.
If a class is looked up with the wrong module prefix, runtime binding calls will
fail with `FailedToLoadClassException`.

SwiftGen provides a diagnostic tool to inspect compiled Mach-O binaries
(`.dylib`, `.framework`, or executables) and detect the Swift modules and
Objective-C classes they export:

```bash
dart run tool/detect_classes.dart <path-to-binary>
```

### Locating Binaries

In Flutter projects, compiled binaries can typically be found in your build directory:
- **Flutter iOS (Device)**: `build/ios/iphoneos/Runner.app/Runner`
- **Flutter iOS (Simulator)**: `build/ios/iphonesimulator/Runner.app/Runner`
- **Embedded Frameworks**: `build/ios/iphoneos/Runner.app/Frameworks/<FrameworkName>.framework/<FrameworkName>`
- **Flutter macOS**: `build/macos/Build/Products/Debug/<App>.app/Contents/MacOS/<App>`

### Configuring Modules in SwiftGen

By default, SwiftGen assigns `output.module` to all generated interfaces and
protocols. If your binary contains classes from multiple modules or external
modules, configure `FfiGeneratorOptions.visitors` in your generation script:

```dart
ffigen: FfiGeneratorOptions(
  visitors: [
    fg.Visitor(
      objCInterface: (node) {
        if (node.name == 'MyClass') {
          node.module = 'MyModule';
        }
      },
    ),
  ],
)
```

