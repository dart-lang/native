An example of a Dart library using a native system libary.

## Note

Note that most system libraries on operating systems will not be available as a
C API. On MacOS/iOS, FFIgen and Swiftgen will need to be used to access the APIs
only available in Objective-C or Swift. On Android, JNIgen will need to be used
to access the APIs only available in Java or Kotlin. This package only details
how to use C APIs. For using system APIs with FFIgen, JNIgen, and Swiftgen refer
to the documentation in these packages.

## Usage

Run tests with `dart --enable-experiment=native-assets test`.

## Code organization

A typical layout of a package which uses system libraries:

* `hook/build.dart` declares the system libraries used.
* `lib/` contains Dart code which uses the system libraries.
