# maven_libs_groovy

This example demonstrates how JNIgen can resolve and generate bindings for
3rd-party Maven dependencies.

The plugin depends on GSON, in `./android/build.gradle`, and the example app
depends on OkHttp in `./example/android/app/build.gradle`. The plugin then
generates bindings for both in `./tool/generate_bindings.dart`.

**Note:** Best practice would be to have the plugin itself depend on both GSON
and OkHttp directly, rather than having indirect dependencies via the example
app. This example is set up the way it is as a stress test for JNIgen's
dependency resolution.

The command to regenerate JNI bindings is:

```bash
dart run tool/generate_bindings.dart
```

The `example/` app must have its dependencies resolved, using `flutter pub get`,
before running JNIgen.

This example is identical to `maven_libs`, but uses Groovy `build.gradle` files
instead of Kotlin.
