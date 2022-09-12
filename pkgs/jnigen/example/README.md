## jnigen examples

This directory contains examples on how to use jnigen.

| Directory | Description |
| ------- | --------- |
| [in_app_java](in_app_java/) | Demonstrates how to include custom Java code in Flutter application and call that using jnigen |
| [pdfbox_plugin](pdfbox_plugin/) | Example of a flutter plugin which provides bindings to Apache PDFBox library. Currently works on Flutter desktop and Dart standalone on linux. |
| [notification_plugin](notification_plugin/) | Example of a reusable Flutter plugin with custom Java code which uses Android libraries. |

We intend to cover few more use cases in future.

Currently supported platforms are Linux (Standalone, Flutter), and Android (Flutter).

## Creating a jnigen-based plugin from scratch

### Dart package (Standalone only)
* Create dart package, add `jni` as dependency and `jnigen` as dev dependency.
* Write the jnigen config similar to [the one in pdfbox_plugin](pdfbox_plugin/jnigen.yaml).
* Generate JNI bindings by running `dart run jnigen --config jnigen.yaml`.

* In the CLI project which uses this package, add this package, and `jni` as a dependency.
* Run `dart run jni:setup && dart run jni:setup -p <generated_package_name>` to build native libraries for JNI base library and your package respectively.
* Import the package. See [pdf_info.dart](pdfbox_plugin/dart_example/bin/pdf_info.dart) for how to use the JNI from dart standalone.

### Flutter FFI plugin
Flutter FFI plugin has the advantage of bundling the required native libraries along with Android / Linux Desktop app.

To create an FFI plugin with JNI bindings:

* Create a plugin using `plugin_ffi` template.
* Remove ffigen-specific files.
* Follow the above steps to generate JNI bindings. The plugin can be used from a flutter project.

* To use the plugin from Dart projects as well, comment-out or remove flutter SDK requirements from the pubspec.

### Android plugin with custom Java code
* Create an FFI plugin with Android as the only platform.
* Build the example/ Android project using command `flutter build apk`. After a release build is done, jnigen can use a gradle stub to collect compile classpaths.
* Write your custom Java code in `android/src/main/java` hierarchy of the plugin.
* Generate JNI bindings as described above. See [notification_plugin/jnigen.yaml](notification_plugin/jnigen.yaml) for example configuration.

