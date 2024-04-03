[![Build Status](https://github.com/dart-lang/native/actions/workflows/jnigen.yaml/badge.svg)](https://github.com/dart-lang/native/actions/workflows/jnigen.yaml)
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/native/badge.svg?branch=main)](https://coveralls.io/github/dart-lang/native?branch=main)
[![pub package](https://img.shields.io/pub/v/jnigen.svg)](https://pub.dev/packages/jnigen)
[![package publisher](https://img.shields.io/pub/publisher/jnigen.svg)](https://pub.dev/packages/jnigen/publisher)

## Introduction
Experimental bindings generator for Java bindings through dart:ffi and JNI.

`jnigen` scans compiled JAR files or Java source code to generate a description of the API, then uses it to generate Dart annd C bindings. The Dart bindings call the C bindings, which in-turn call the Java functions through JNI. Shared functionality and base classes are provided through the support library, `package:jni`.

The configuration for binding generation is usually provided through YAML.

Three configuration details are needed to generate the bindings. Everything else is optional:

* _Inputs_: input can be Java source files (`source_path`), or compiled classes / JARs (`class_path`). Some maven / gradle based tooling is also provided to simplify obtaining dependencies.

* _Outputs_: Output can be generated in package-structured (one file per class) or single file bindings. Target path to write C and Dart bindings needs to be specified.

* _Classes_: Specify which classes or packages you need bindings for. Specifying a package includes all classes inside it recursively.

Check out the [examples](jnigen/example/) to see some sample configurations.

C code is always generated into a directory with it's own build configuration. It's built as a separate dynamic library.

Lastly, [dart_only bindings](#pure-dart-bindings) mode is also available as a proof-of-concept. It does not need intermediate C bindings, only a dependency on the support library `package:jni`.

## Example
It's possible to generate bindings for JAR libraries, or Java source files.

Here's a simple example Java file, in a Flutter Android app.

```java
package com.example.in_app_java;

import android.app.Activity;
import android.widget.Toast;
import androidx.annotation.Keep;

@Keep
public abstract class AndroidUtils {
  // Hide constructor
  private AndroidUtils() {}

  public static void showToast(Activity mainActivity, CharSequence text, int duration) {
    mainActivity.runOnUiThread(() -> Toast.makeText(mainActivity, text, duration).show());
  }
}
```

This produces the following boilerplate:

#### Dart Bindings:

```dart
/// Some boilerplate is omitted for clarity.
final ffi.Pointer<T> Function<T extends ffi.NativeType>(String sym) jniLookup =
    ProtectedJniExtensions.initGeneratedLibrary("android_utils");

/// from: com.example.in_app_java.AndroidUtils
class AndroidUtils extends jni.JObject {
  AndroidUtils.fromReference(JReference reference) : super.fromReference(reference);

  static final _showToast = jniLookup<
          ffi.NativeFunction<
              jni.JniResult Function(ffi.Pointer<ffi.Void>,
                  ffi.Pointer<ffi.Void>, ffi.Int32)>>("AndroidUtils__showToast")
      .asFunction<
          jni.JniResult Function(
              ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Void>, int)>();

  /// from: static public void showToast(android.app.Activity mainActivity, java.lang.CharSequence text, int duration)
  static void showToast(
          jni.JObject mainActivity, jni.JObject text, int duration) =>
      _showToast(mainActivity.reference, text.reference, duration).check();
}
```

#### C Bindings:

```c
// Some boilerplate is omitted for clarity.

// com.example.in_app_java.AndroidUtils
jclass _c_AndroidUtils = NULL;

jmethodID _m_AndroidUtils__showToast = NULL;
FFI_PLUGIN_EXPORT
JniResult AndroidUtils__showToast(jobject mainActivity,
                                  jobject text,
                                  int32_t duration) {
  load_env();
  load_class_gr(&_c_AndroidUtils, "com/example/in_app_java/AndroidUtils");
  if (_c_AndroidUtils == NULL)
    return (JniResult){.result = {.j = 0}, .exception = check_exception()};
  load_static_method(_c_AndroidUtils, &_m_AndroidUtils__showToast, "showToast",
                     "(Landroid/app/Activity;Ljava/lang/CharSequence;I)V");
  if (_m_AndroidUtils__showToast == NULL)
    return (JniResult){.result = {.j = 0}, .exception = check_exception()};
  (*jniEnv)->CallStaticVoidMethod(jniEnv, _c_AndroidUtils,
                                  _m_AndroidUtils__showToast, mainActivity,
                                  text, duration);
  return (JniResult){.result = {.j = 0}, .exception = check_exception()};
}
```

The YAML configuration used to generate the above code looks like this:

```yaml
android_sdk_config:
  add_gradle_deps: true

output:
  c:
    library_name: android_utils
    path: src/android_utils/
  dart:
    path: lib/android_utils.dart
    structure: single_file

source_path:
  - 'android/app/src/main/java'
classes:
  - 'com.example.in_app_java.AndroidUtils'
```

The complete example can be found in [jnigen/example/in_app_java](jnigen/example/in_app_java), which adds few more classes to demonstrate using classes from gradle JAR and source dependencies.

## Supported platforms
| Platform | Dart Standalone | Flutter       |
| -------- | --------------- | ------------- |
| Android  | n/a             | Supported     |
| Linux    | Supported       | Supported     |
| Windows  | Supported       | Supported     |
| MacOS    | Supported       | Not Yet       |

On Android, the flutter application runs embedded in Android JVM. On other platforms, a JVM needs to be explicitly spawned using `Jni.spawn`. `package:jni` provides the infrastructure for initializing and managing the JNI on both Android and Non-Android platforms.

## Java features support
Currently basic features of the Java language are supported in the bindings. Each Java class is mapped to a Dart class. Bindings are generated for methods, constructors and fields. Exceptions thrown in Java are rethrown in Dart with stack trace from Java.

More advanced features such as callbacks are not supported yet. Support for these features is tracked in the [issue tracker](https://github.com/dart-lang/native/issues?q=is%3Aopen+is%3Aissue+label%3Apackage%3Ajni%2Cpackage%3Ajnigen).

## Note on Dart (standalone) target
`package:jni` is an FFI plugin containing native code, and any bindings generated from jnigen contains native code too.

On Flutter targets, native libraries are built automatically and bundled. On standalone platforms, no such infrastructure exists yet. As a stopgap solution, running `dart run jni:setup` in a target directory builds all JNI native dependencies of the package into `build/jni_libs`. 

By default `jni:setup` goes through pubspec configuration and builds all JNI dependencies of the project. It can be overridden to build a custom directory using `-s` switch, which can be useful when output configuration for C bindings does not follow standard FFI plugin layout.

The build directory has to be passed to `Jni.spawn` call. It's assumed that all dependencies are built into the same target directory, so that once JNI is initialized, generated bindings can load their respective C libraries automatically.

## Requirements
### SDK
Flutter SDK is required.

Dart standalone target is supported, but due to some problems with pubspec format, the `dart` command must be from Flutter SDK and not Dart SDK. See [dart-lang/pub#3563](https://github.com/dart-lang/pub/issues/3563).

### Java tooling

**Use JDK versions 11 to 17. The newer versions will not work because of their lack of [compatibility](https://docs.gradle.org/current/userguide/compatibility.html) with Gradle.**

Along with JDK, maven (`mvn` command) is required. On windows, it can be installed using a package manager such as [chocolatey](https://community.chocolatey.org/packages/maven) or [scoop](https://scoop.sh/#/apps?q=maven).

__On windows, append the path of `jvm.dll` in your JDK installation to PATH.__

For example, on Powershell:

```powershell
$env:Path += ";${env:JAVA_HOME}\bin\server".
```

If JAVA_HOME not set, find the `java.exe` executable and set the environment variable in Control Panel. If java is installed through a package manager, there may be a more automatic way to do this. (Eg: `scoop reset`).

### C/C++ tooling
CMake and a standard C toolchain are required to build `package:jni` and C bindings generated by `jnigen`.

It's recommended to have `clang-format` installed for formatting the generated C bindings. On Windows, it's part of LLVM installation. On most Linux distributions it is available as a separate package. On MacOS, it can be installed using Homebrew.

## FAQs

#### I am getting ClassNotFoundError at runtime.
`jnigen` does not handle getting the classes into application. It has to be done by target-specific mechanism. Such as adding a gradle dependency on Android, or manually providing classpath to `Jni.spawn` on desktop / standalone targets.

On Android, `proguard` prunes classes which it deems inaccessible. Since JNI class lookup happens in runtime, this leads to ClassNotFound errors in release mode even if the dependency is included in gradle. [in_app_java example](jnigen/example/in_app_java/) discusses two mechanisms to prevent this: using `Keep` annotation (`androidx.annotation.Keep`) for the code written in the application itself, and [proguard-rules file](jnigen/example/in_app_java/android/app/proguard-rules.pro) for external libraries.

Lastly, some libraries such as `java.awt` do not exist in android. Attempting to use libraries which depend on them can also lead to ClassNotFound errors.

#### `jnigen` is not finding classes.
Ensure you are providing correct source and class paths, and they follow standard directory structure. If your class name is `com.abc.MyClass`, `MyClass` must be in `com/abc/MyClass.java` relative to one of the source paths, or `com/abc/MyClass.class` relative to one of the class paths specified in YAML.

If the classes are in JAR file, make sure to provide path to JAR file itself, and not the containing directory.

#### `jnigen` is unable to parse sources.
If the errors are similar to `symbol not found`, ensure all dependencies of the source are available. If such dependency is compiled, it can be included in `class_path`.

#### How are classes mapped into bindings?
Each Java class generates a subclass of `JObject` class, which wraps a `jobject` reference in JNI. Nested classes use `_` as separator, `Example.NestedClass` will be mapped to `Example_NestedClass`.

#### Does `JObject` hold a local or global reference? Does it need to be manually released?
Each Java object returned into Dart creates a JNI global reference. Reference deletion is taken care of by `NativeFinalizer` and that's usually sufficient.

It's a good practice to keep the interface between languages sparse. However, if there's a need to create several references (Eg: in a loop), you can use FFI Arena mechanism (`using` function) and `releasedBy` method, or manually release the object using `release` method.

#### Should I use `jnigen` over Method channels?
This is currently an experimental package. Many features are missing, and it's rough around the edges. You're welcome to try it and give feedback.

## YAML Configuration Reference
Keys ending with a colon (`:`) denote subsections.

The typical invocation with YAML configuration is

```
dart run jnigen --config jnigen.yaml
```

Any configuration can be overridden through command line using `-D` or `--override` switch. For example `-Dlog_level=warning` or `-Dsummarizer.backend=asm`. (Use `.` to separate subsection and property name).

A `*` denotes required configuration.

| Configuration property | Type / Values | Description                                                             |
| ---------------------- | ------------- | ----------------------------------------------------------------------- |
| `preamble`             | Text          | Text to be pasted in the start of each generated file.                  |
| `source_path`          | List of directory paths | Directories to search for source files. Note: source_path for dependencies downloaded using `maven_downloads` configuration is added automatically without the need to specify here. |
| `class_path`           | List of directory / JAR paths | Classpath for API summary generation. This should include any JAR dependencies of the source files in `source_path`. |
| `classes` *            | List of qualified class / package names | List of qualified class / package names. `source_path` will be scanned assuming the sources follow standard java-ish hierarchy. That is a.b.c either maps to a directory `a/b/c` or a class file `a/b/c.java`.  |
| `enable_experiment`    | List of experiment names:<br><ul><li>`interface_implementation`</li></ul> | List of enabled experiments. These features are still in development and their API might break.  |
| `output:`              | (Subsection) | This subsection will contain configuration related to output files. |
| `output:` >> `bindings_type` | `c_based` (default) or `dart_only` | Binding generation strategy. [Trade-offs](#pure-dart-bindings) are explained at the end of this document. |
| `output:` >> `c:`      | (Subsection) | This subsection specified C output configuration. Required if `bindings_type` is `c_based`. |
| `output:` >> `c:` >> path *       | Directory path | Directory to write C bindings. Usually `src/` in case of an FFI plugin template. |
| `output:` >> `c:` >> subdir       | Directory path | If specified, C bindings will be written to `subdir` resolved relative to `path`. This is useful when bindings are supposed to be under source's license, and written to a subdirectory such as `third_party`. |
| `output:` >> `c:` >> `library_name` *| Identifier (snake_case) | Name for generated C library.
| `output:` >> `dart:` | (Subsection) | This subsection specifies Dart output configuration. |
| `output:` >> `dart:` >> `structure` | `package_structure` / `single_file` | Whether to map resulting dart bindings to file-per-class source layout, or write all bindings to single file.
| `output:` >> `dart:` >> `path` * | Directory path or File path | Path to write Dart bindings. Should end in `.dart` for `single_file` configurations, and end in `/` for `package_structure` (default) configuration. |
| `maven_downloads:`     | (Subsection) | This subsection will contain configuration for automatically downloading Java dependencies (source and JAR) through maven. |
| `maven_downloads:` >> `source_deps` | List of maven package coordinates | Source packages to download and unpack using maven. The names should be valid maven artifact coordinates. (Eg: `org.apache.pdfbox:pdfbox:2.0.26`). The downloads do not include transitive dependencies. |
| `maven_downloads:` >> `source_dir` | Path | Directory in which maven sources are extracted. Defaults to `mvn_java`. It's not required to list this explicitly in source_path. |
| `maven_downloads:` >> `jar_only_deps` | List of maven package coordinates | JAR dependencies to download which are not mandatory transitive dependencies of `source_deps`. Often, it's required to find and include optional dependencies so that entire source is valid for further processing. |
| `maven_downloads:` >> `jar_dir` | Path | Directory to store downloaded JARs. Defaults to `mvn_jar`. |
| `log_level`            | Logging level | Configure logging level. Defaults to `info`.                            |
| `android_sdk_config:`  | (Subsection)  | Configuration for autodetection of Android dependencies and SDK. Note that this is more experimental than others, and very likely subject to change. |
| `android_sdk_config:` >> `add_gradle_deps` | Boolean | If true, run a gradle stub during `jnigen` invocation, and add Android compile classpath to the classpath of jnigen. This requires a release build to have happened before, so that all dependencies are cached appropriately. |
| `android_sdk_config:` >> `android_example` | Directory path | In case of an Android plugin project, the plugin itself cannot be built and `add_gradle_deps` is not directly feasible. This property can be set to relative path of package example app (usually `example/` so that gradle dependencies can be collected by running a stub in this directory. See [notification_plugin example](jnigen/example/notification_plugin/jnigen.yaml) for an example. |
| `summarizer:`          | (Subsection)  | Configuration specific to summarizer component, which builds API descriptions from Java sources or JAR files. |
| `summarizer:` >> `backend` | `auto`, `doclet` or `asm` | Specifies the backend to use in API summary generation. `doclet` uses OpenJDK Doclet API to build summary from sources. `asm` uses ASM library to build summary from classes in `class_path` JARs. `auto` attempts to find the class in sources, and falls back to using ASM. |
| `summarizer:` >> `extra_args` (DEV) | List of CLI arguments | Extra arguments to pass to summarizer JAR. |
| `exclude:`             | (Subsection)  | Exclude methods or fields using regex filters. It's generally useful to exclude problematic fields or methods which, with current binding generation, can lead to syntax errors |
| `exclude:` >> `methods`| List of methods in `classBinaryName#methodName` format where classBinaryName is same as qualified name, but `$` preceding a nested class instead of `.`. Example: `com.example.MyClass` or `com.example.MyClass$NestedClass` | Methods to exclude.
| `exclude:` >> `fields` | List of fields in `classBinaryName#fieldName` format | Fields to exclude.

It's possible to use the programmatic API instead of YAML.

* Create a tool script. (Eg: `tool/generate_jni_bindings.dart`)
* import `package:jnigen/jnigen.dart`
* construct a `Config` object and pass it to `generateJniBindings` function. The parameters are similar to the ones described above.

## Pure dart Bindings
It's possible to generate bindings that do not rely on an intermediate layer of C code. Bindings will still depend on `package:jni` and its support library written in C. But this approach avoids large C bindings.

To enable pure dart bindings, specify
```
output:
	bindings_type: dart_only
```

Any C output configuration will be ignored.

However, pure dart bindings will require additional allocations and check runtimeType of the arguments. This will be the case until Variadic arguments land in Dart FFI.

## Android core libraries
These days, Android projects depend heavily on AndroidX and other libraries downloaded via gradle. We have a tracking issue to improve detection of android SDK and dependencies. (#31). Currently we can fetch the JAR dependencies of an android project, by running a gradle stub, if `android_sdk_config` >> `add_gradle_deps` is specified. 

But core libraries (the `android.**` namespace) are not downloaded through gradle. The core libraries are shipped as stub JARs with the Android SDK. (`$SDK_ROOT/platforms/android-$VERSION/android-stubs-src.jar`).

Currently we don't have an automatic mechanism for using these. You can unpack this JAR manually into some directory and provide it as a source path.

However there are 2 caveats to this caveat.

* SDK stubs after version 28 are incomplete. OpenJDK Doclet API we use to generate API summaries will error on incomplete sources.
* The API can't process the `java.**` namespaces in the Android SDK stubs, because it expects a module layout. So if you want to generate bindings for, say, `java.lang.Math`, you cannot use the Android SDK stubs. OpenJDK sources can be used instead.

The JAR files (`$SDK_ROOT/platforms/android-$VERSION/android.jar`) can be used instead. But compiled JARs do not include JavaDoc and method parameter names. This JAR is automatically included by Gradle when `android_sdk_config` >> `add_gradle_deps` is specified.

## Migrating to 0.8.0

Check [`jni`'s changelog](https://github.com/dart-lang/native/blob/main/pkgs/jni/CHANGELOG.md#080-wip) and [`jnigen`'s changelog](https://github.com/dart-lang/native/blob/main/pkgs/jnigen/CHANGELOG.md#080-wip).

## Contributing
See the wiki for architecture-related documents.

