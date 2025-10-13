[![Build Status](https://github.com/dart-lang/native/actions/workflows/jnigen.yaml/badge.svg)](https://github.com/dart-lang/native/actions/workflows/jnigen.yaml)
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)
[![pub package](https://img.shields.io/pub/v/jnigen.svg)](https://pub.dev/packages/jnigen)
[![package publisher](https://img.shields.io/pub/publisher/jnigen.svg)](https://pub.dev/packages/jnigen/publisher)

## Introduction

Bindings generator to call Java APIs from Dart code via `dart:ffi` and JNI.

JNIgen scans compiled JAR files or Java source code to generate a description
of the API, then uses that to generate Dart bindings. The Dart bindings call the
C bindings, which in-turn call the Java functions through JNI. Shared 
functionality and base classes are provided through the support library,
`package:jni`.

## Getting Started

This guide demonstrates how to call a custom Java API from a Flutter
application targeting Android. It assumes that Flutter has been set up to build
apps for Android 
([instructions](https://docs.flutter.dev/platform-integration/android/setup))
and that the Flutter app was created via `flutter create in_app_java`. If you
encounter any issues running the commands below, check the
[Requirements](#requirements) section below for additional platform-specific
instructions.

1. Run `flutter build apk` at least once to build an APK for your app. This is 
   necessary so that JNIgen can get the classpaths of Android Gradle
   libraries.

2. Add the helper package `package:jni` as a dependency and the bindings
   generator `package:jnigen` as a dev_dependency to the pubspec of your app by
   running: `flutter pub add jni dev:jnigen`.

3. Write the Java code and place it in the `android/` subproject of your app.
   For this example, we'll place the following code under 
   `android/app/src/main/java/com/example/in_app_java/AndroidUtils.java`. It
   defines a simple Java API to show a native Android toast.

   ```java
   package com.example.in_app_java;

   import android.app.Activity;
   import android.widget.Toast;
   import androidx.annotation.Keep;

   @Keep
   public abstract class AndroidUtils { 
       private AndroidUtils() {} // Hide constructor

       public static void showToast(Activity mainActivity, CharSequence text, int duration) {
           mainActivity.runOnUiThread(() -> Toast.makeText(mainActivity, text, duration).show());
       }
   }
   ```

4. To generate the bindings, we will write a script using `package:jnigen` and 
   place it under `tool/jnigen.dart`. The script constructs a `Config` object
   and passes it to `generateJniBindings`. The `Config` object configures the
   bindings that JNIgen will generate for the Java code. Refer to the code
   comments below and the API docs to learn more about available configuration
   options.

   ```dart
   import 'dart:io';

   import 'package:jnigen/jnigen.dart';

   void main(List<String> args) {
     final packageRoot = Platform.script.resolve('../');
     generateJniBindings(
       Config(
         outputConfig: OutputConfig(
           dartConfig: DartCodeOutputConfig(
             // Required. Output path for generated bindings.
             path: packageRoot.resolve('lib/android_utils.g.dart'),
             // Optional. Write bindings into a single file (instead of one file per class).
             structure: OutputStructure.singleFile,
           ),
         ),
         // Optional. Configuration to search for Android SDK libraries.
         androidSdkConfig: AndroidSdkConfig(addGradleDeps: true),
         // Optional. List of directories that contain the source files for which to generate bindings.
         sourcePath: [packageRoot.resolve('android/app/src/main/java')],
         // Required. List of classes or packages for which bindings should be generated.
         classes: ['com.example.in_app_java'],
       ),
     );
   }
   ```

5. Run the script with `dart run tool/jnigen.dart` to generate the bindings.
   This will create the output `android_utils.g.dart` file, which can be
   imported by Dart code to access the Java APIs. This command must be re-run
   whenever the JNIgen configuration (in `tool/jnigen.dart`) or the Java
   sources for which bindings are generated change.

6. Import `android_utils.g.dart` in your Flutter app and call the generated
   methods to access the native Java API:

   ```dart
   import 'package:jni/jni.dart';

   import 'android_utils.g.dart';

   // ...

   void showToast() {
     JObject activity = JObject.fromReference(Jni.getCurrentActivity());
     final message = 'This is a native toast shown from a Flutter app via JNI.';
     AndroidUtils.showToast(activity, message.toJString(), 0);
   }
   ```

That's it! Run your app with `flutter run` on an Android device to see it in
action.

The complete example can be found in
[jnigen/example/in_app_java](example/in_app_java), which adds a few more classes
to demonstrate using classes from Gradle JAR and source dependencies.

## More Examples

Additional examples showcasing how JNIgen can be used in different scenarios
(e.g. to generate bindings for Kotlin) can be found in the [example](example/)
directory.

## Supported platforms

| Platform | Dart Standalone | Flutter   |
|----------|-----------------|-----------|
| Android  | n/a             | Supported |
| Linux    | Supported       | Supported |
| Windows  | Supported       | Supported |
| macOS    | Supported       | Not Yet   |

On Android, the Flutter application runs embedded in the Android JVM. On other
platforms, a JVM needs to be explicitly spawned using `Jni.spawn`. The helper
package `package:jni` provides the infrastructure for initializing and managing
the JNI on both Android and non-Android platforms.

## Dart (standalone) target

`package:jni` is an FFI plugin containing native code, and any bindings
generated from JNIgen contain native code too.

On Flutter targets, native libraries are built automatically and bundled. On
standalone platforms, no such infrastructure exists yet. As a stopgap solution,
running `dart run jni:setup` in a target directory builds all JNI native
dependencies of the package into `build/jni_libs`. 

To start a JVM, call `Jni.spawn`. It's assumed that all dependencies are built
into the same target directory, so that once JNI is initialized, generated
bindings can load their respective C libraries automatically.

If a custom build path has been set for the dynamic libraries built by
`dart run jni:setup --build-path path/to/dylib`, the same path must be passed to
`Jni.spawn`. Also, anytime a new Dart isolate is spawned, the directory must be
set again using `Jni.setDylibDir`.

## Requirements

### SDK

Flutter SDK is required.

Dart standalone target is supported, but due to some problems with pubspec
format, the `dart` command must be from the Flutter SDK and not Dart SDK. See
[dart-lang/pub#3563](https://github.com/dart-lang/pub/issues/3563).

### Java tooling

Use JDK versions 11 to 17. The newer versions will not work because of their
lack of
[compatibility](https://docs.gradle.org/current/userguide/compatibility.html)
with Gradle.

#### Windows

On windows, append the path of `jvm.dll` in your JDK installation to PATH. For
example, on PowerShell:
```powershell
$env:Path += ";${env:JAVA_HOME}\bin\server"
```

The above will only add `jvm.dll` to `PATH` for the current PowerShell session,
use the Control Panel to add it to the path permanently.

If JAVA_HOME not set, find the `java.exe` executable and set the environment
variable in Control Panel. If java is installed through a package manager, there
may be a more automatic way to do this. (e.g. `scoop reset`).

### C tooling

CMake and a standard C toolchain are required to build `package:jni`.

## YAML Configuration Reference

In addition to the Dart API shown in the "Getting Started" section, JNIgen can
also be configured via a YAML configuration file. Support for the YAML
configuration will be eventually phased out, and using the Dart API is 
recommended. To generate bindings with a YAML configuration stored in
`jnigen.yaml` use the following command:

```
dart run jnigen --config jnigen.yaml
```

Any configuration can be overridden through the command line using the `-D` or
`--override` switch, for example `-Dlog_level=warning` or 
`-Dsummarizer.backend=asm`. (Use `.` to separate subsection and property name.)

The table below documents the available YAML configuration options. Keys ending
with a colon (`:`) denote subsections. A `*` denotes a required configuration.

| Configuration property                     | Type / Values                                                             | Description                                                                                                                                                                                                                                                                                                                                                                               |
|--------------------------------------------|---------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `preamble`                                 | Text                                                                      | Text to be pasted in the start of each generated file.                                                                                                                                                                                                                                                                                                                                    |
| `source_path`                              | List of directory paths                                                   | Directories to search for source files. Note: `source_path` for dependencies downloaded using `maven_downloads` configuration is added automatically without the need to specify here.                                                                                                                                                                                                    |
| `class_path`                               | List of directory / JAR paths                                             | Classpath for API summary generation. This should include any JAR dependencies of the source files in `source_path`.                                                                                                                                                                                                                                                                      |
| `classes` *                                | List of qualified class / package names                                   | List of qualified class / package names. `source_path` will be scanned assuming the sources follow standard java-ish hierarchy. That is a.b.c either maps to a directory `a/b/c` or a class file `a/b/c.java`.                                                                                                                                                                            |
| `enable_experiment`                        | List of experiment names:<br><ul><li>`interface_implementation`</li></ul> | List of enabled experiments. These features are still in development and their API might break.                                                                                                                                                                                                                                                                                           |
| `output:`                                  | (Subsection)                                                              | This subsection will contain configuration related to output files.                                                                                                                                                                                                                                                                                                                       |
| `output:` >> `dart:`                       | (Subsection)                                                              | This subsection specifies Dart output configuration.                                                                                                                                                                                                                                                                                                                                      |
| `output:` >> `dart:` >> `structure`        | `package_structure` / `single_file`                                       | Whether to map resulting dart bindings to file-per-class source layout, or write all bindings to single file.                                                                                                                                                                                                                                                                             |
| `output:` >> `dart:` >> `path` *           | Directory path or File path                                               | Path to write Dart bindings. Should end in `.dart` for `single_file` configurations, and end in `/` for `package_structure` (default) configuration.                                                                                                                                                                                                                                      |
| `non_null_annotations:`                    | List of annotation fully qualified names                                  | List of custom annotations that specify if the annotation type is non-nullable.                                                                                                                                                                                                                                                                                                           |
| `nullable_annotations:`                    | List of annotation fully qualified names                                  | List of custom annotations that specify if the annotation type is nullable.                                                                                                                                                                                                                                                                                                               |
| `maven_downloads:`                         | (Subsection)                                                              | This subsection will contain configuration for automatically downloading Java dependencies (source and JAR) through maven.                                                                                                                                                                                                                                                                |
| `maven_downloads:` >> `source_deps`        | List of maven package coordinates                                         | Source packages to download and unpack using maven. The names should be valid maven artifact coordinates. (Eg: `org.apache.pdfbox:pdfbox:2.0.26`). The downloads do not include transitive dependencies.                                                                                                                                                                                  |
| `maven_downloads:` >> `source_dir`         | Path                                                                      | Directory in which maven sources are extracted. Defaults to `mvn_java`. It's not required to list this explicitly in `source_path`.                                                                                                                                                                                                                                                       |
| `maven_downloads:` >> `jar_only_deps`      | List of maven package coordinates                                         | JAR dependencies to download which are not mandatory transitive dependencies of `source_deps`. Often, it's required to find and include optional dependencies so that entire source is valid for further processing.                                                                                                                                                                      |
| `maven_downloads:` >> `jar_dir`            | Path                                                                      | Directory to store downloaded JARs. Defaults to `mvn_jar`.                                                                                                                                                                                                                                                                                                                                |
| `log_level`                                | Logging level                                                             | Configure logging level. Defaults to `info`.                                                                                                                                                                                                                                                                                                                                              |
| `android_sdk_config:`                      | (Subsection)                                                              | Configuration for autodetection of Android dependencies and SDK. Note that this is more experimental than others, and very likely subject to change.                                                                                                                                                                                                                                      |
| `android_sdk_config:` >> `add_gradle_deps` | Boolean                                                                   | If true, run a Gradle stub during JNIgen invocation, and add Android compile classpath to the classpath of JNIgen. This requires a release build to have happened before, so that all dependencies are cached appropriately.                                                                                                                                                              |
| `android_sdk_config:` >> `android_example` | Directory path                                                            | In case of an Android plugin project, the plugin itself cannot be built and `add_gradle_deps` is not directly feasible. This property can be set to relative path of package example app (usually `example/` so that Gradle dependencies can be collected by running a stub in this directory. See [notification_plugin example](example/notification_plugin/jnigen.yaml) for an example. |
| `summarizer:`                              | (Subsection)                                                              | Configuration specific to summarizer component, which builds API descriptions from Java sources or JAR files.                                                                                                                                                                                                                                                                             |
| `summarizer:` >> `backend`                 | `auto`, `doclet` or `asm`                                                 | Specifies the backend to use in API summary generation. `doclet` uses OpenJDK Doclet API to build summary from sources. `asm` uses ASM library to build summary from classes in `class_path` JARs. `auto` attempts to find the class in sources, and falls back to using ASM.                                                                                                             |
| `summarizer:` >> `extra_args` (DEV)        | List of CLI arguments                                                     | Extra arguments to pass to summarizer JAR.                                                                                                                                                                                                                                                                                                                                                |

## FAQs

#### I am getting ClassNotFoundError at runtime.
JNIgen does not handle getting the classes into application. It has to be done
by target-specific mechanism. Such as adding a Gradle dependency on Android, or
manually providing classpath to `Jni.spawn` on desktop / standalone targets.

On Android, `proguard` prunes classes which it deems inaccessible. Since JNI
class lookup happens in runtime, this leads to ClassNotFound errors in release
mode even if the dependency is included in Gradle.
[in_app_java example](example/in_app_java/) discusses two mechanisms to prevent
this: using `Keep` annotation (`androidx.annotation.Keep`) for the code written
in the application itself, and
[proguard-rules file](example/in_app_java/android/app/proguard-rules.pro) for
external libraries.

Lastly, some libraries such as `java.awt` do not exist in Android. Attempting to
use libraries which depend on them can also lead to ClassNotFound errors.

#### JNIgen is not finding classes.
Ensure you are providing the correct source and class paths, and they follow the
standard directory structure. If your class name is `com.abc.MyClass`,
`MyClass` must be in `com/abc/MyClass.java` relative to one of the source paths,
or `com/abc/MyClass.class` relative to one of the class paths specified in YAML.

If the classes are in JAR file, make sure to provide the path to the JAR file
itself, and not to the containing directory.

#### JNIgen is unable to parse sources.
If the errors are similar to `symbol not found`, ensure all dependencies of the
source are available. If such dependency is compiled, it can be included in
`class_path`.

#### Generate bindings for built-in types
For your convenience, a number of built-in Java types, for example, many of
those in `java.lang` and `java.util`, are provided to your build by `jni` by
default.

Those don't need to be included in the classes block, and will error if you do
so, with the following error: 
`Fatal: Trying to re-import the generated classes`.

For any other types that are in core Java, you can add them in your `classes`
block and bindings will be generated when you run the generate bindings task.

Below is a snippet of a YAML configuration showing how you might generate
bindings for several classes in `java.time.*` and a `java.lang` class that is
not included by default.

``` yaml
output:
  dart:
    path: lib/gen/

classes:
  - 'java.time.Instant'
  - 'java.time.ZoneOffset'
  - 'java.time.ZonedDateTime'
  - 'java.lang.Math'
# - 'java.lang.Integer' # Will error, already included in binary
```

#### How are classes mapped into bindings?
Each Java class generates a subclass of `JObject` class, which wraps a `jobject`
reference in JNI. Nested classes use `_` as separator, `Example.NestedClass`
will be mapped to `Example_NestedClass`.

#### Does `JObject` hold a local or global reference? Does it need to be manually released?
Each Java object returned into Dart creates a JNI global reference. Reference
deletion is taken care of by `NativeFinalizer` and that's usually sufficient.

It's a good practice to keep the interface between languages sparse. However, if
there's a need to create several references (e.g. in a loop), you can use the
FFI Arena mechanism (`using` function) and `releasedBy` method, or manually
release the object using `release` method.

## Android core libraries
These days, Android projects depend heavily on AndroidX and other libraries
downloaded via Gradle. We have a tracking issue to improve detection of Android
SDK and dependencies ([#793](https://github.com/dart-lang/native/issues/793)).
Currently, we can fetch the JAR dependencies of an Android project, by running a
Gradle stub, if `android_sdk_config` >> `add_gradle_deps` is specified. However,
core libraries (the `android.**` namespace) are not downloaded through Gradle.
The core libraries are shipped as stub JARs with the Android SDK.
(`$SDK_ROOT/platforms/android-$VERSION/android-stubs-src.jar`). Currently, we
don't have an automatic mechanism for using these. You can unpack this JAR
manually into some directory and provide it as a source path.

Having said that, there are two caveats to this caveat:

* SDK stubs after version 28 are incomplete. OpenJDK Doclet API we use to
  generate API summaries will error on incomplete sources.
* The API can't process the `java.**` namespaces in the Android SDK stubs, 
  because it expects a module layout. So if you want to generate bindings for,
  say, `java.lang.Math`, you cannot use the Android SDK stubs. OpenJDK sources
  can be used instead. See 
  [Generate bindings for built-in types](#generate-bindings-for-built-in-types)
  above for instructions on how to use OpenJDK sources.

The JAR files (`$SDK_ROOT/platforms/android-$VERSION/android.jar`) can be used
instead. But compiled JARs do not include JavaDoc and method parameter names.
This JAR is automatically included by Gradle when 
`android_sdk_config` >> `add_gradle_deps` is specified.

## Contributing
See [CONTRIBUTING.md](../../CONTRIBUTING.md) in the root of the repository for
information on how to contribute.
