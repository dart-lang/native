#### Developer's Note

One-off patch of [ffigen](https://github.com/dart-lang/ffigen) for generating bindings of some JNI structs.

Only changes to ffigen source are made in lib/src/code_generator/compound.dart file. The purpose of these changes is to write the extension methods along with certain types, which make calling function pointer fields easier.

The modified FFIGEN is used to generate `lib/src/third_party/jni_bindings_generated.dart` using both header files in src/ and third_party/jni.h (the JNI header file from Android NDK). This provides bulk of our interface to JNI through FFI.

