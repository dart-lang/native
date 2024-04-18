# In-App Java Example

This example shows how to write custom java code in `android/app/src` and call
it using `jnigen` generated bindings.

#### How to run this example:

- Run `flutter run` to run the app.

- To regenerate bindings after changing Java code, run
  `flutter pub run jnigen --config jnigen.yaml`. This requires at least one APK
  build to have been run before, so that it's possible for `jnigen` to obtain
  classpaths of Android Gradle libraries. Therefore, once run
  `flutter build apk` before generating bindings for the first time, or after a
  `flutter clean`.

#### General steps

These are general steps to integrate Java code into a flutter project using
`jnigen`.

- Write Java code in suitable package folder, under `android/` subproject of the
  flutter app.
- Create A jnigen config like `jnigen.yaml` in this example.
- Generate bindings using jnigen config.
- Add proguard rules to exclude your custom classes from tree shaking, since
  they are always accessed reflectively in JNI.
- Build and run the app.
