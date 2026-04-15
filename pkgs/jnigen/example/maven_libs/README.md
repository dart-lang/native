# maven_libs

This example demonstrates how JNIgen can resolve and generate bindings for 3rd-party Maven dependencies (like GSON and OkHttp) in a Kotlin-based Android project without requiring a full build.

It uses the programmatic Dart API for configuration instead of a YAML file, and demonstrates a pure JNI-based plugin without Method Channel boilerplate.

The command to regenerate JNI bindings is:
```bash
dart run tool/generate_bindings.dart # run from maven_libs project root
```

## Features

- **Build-less Resolution:** Demonstrates JNIgen's ability to extract `classes.jar` from AAR dependencies in the Gradle cache immediately after a `flutter pub get`.
- **Kotlin DSL Support:** Uses modern `build.gradle.kts` files for both the plugin and the example app.
- **Complex Dependency Graph:** The plugin depends on GSON, while the example app depends on OkHttp. JNIgen correctly identifies and captures both.
- **Programmatic Configuration:** Uses `tool/generate_bindings.dart` to configure JNIgen via the `Config` and `AndroidSdkConfig` classes.

## Prerequisites

Ensure the example app's dependencies are resolved before running the generator:
```bash
cd example
flutter pub get
```
Unlike older versions of JNIgen, a full `flutter build apk` is not required.
