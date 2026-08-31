# notification_plugin

Example of Android plugin project with JNIgen.

This plugin project contains [custom code](android/src/main/java/com/example/notification_plugin) which uses the Android libraries. The bindings are generated using [JNIgen script](tool/jnigen.dart) and then used in [flutter example](example/lib/main.dart), with help of `package:jni` APIs.

The command to regenerate JNI bindings is:
```bash
dart run tool/jnigen.dart
```

The `example/` app must have its dependencies resolved (eg `flutter pub get`) before running JNIgen.

