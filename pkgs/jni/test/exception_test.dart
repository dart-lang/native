import 'dart:io';

import 'package:test/test.dart';

import 'package:jni/jni.dart';
import 'package:jni/jni_object.dart';

void main() {
  if (!Platform.isAndroid) {
    bool caught = false;
    try {
      // If library does not exist, a helpful exception should be thrown.
      // we can't test this directly because
      // `test` schedules functions asynchronously
      Jni.spawn(helperDir: "wrong_dir");
    } on HelperNotFoundException catch (_) {
      // stderr.write("\n$_\n");
      Jni.spawn(helperDir: "src/build");
      caught = true;
    }
    if (!caught) {
      throw "Expected HelperNotFoundException\n"
          "Read exception_test.dart for details.";
    }
  }
  final jni = Jni.getInstance();

  test("double free throws exception", () {
    final r = jni.newInstance("java/util/Random", "()V", []);
    r.delete();
    expect(r.delete, throwsA(isA<DoubleFreeException>()));
  });

  test("Use after free throws exception", () {
    final r = jni.newInstance("java/util/Random", "()V", []);
    r.delete();
    expect(() => r.callIntMethodByName("nextInt", "(I)I", [256]),
        throwsA(isA<UseAfterFreeException>()));
  });

  test("An exception in JNI throws JniException in Dart", () {
    final r = jni.newInstance("java/util/Random", "()V", []);
    expect(() => r.callIntMethodByName("nextInt", "(I)I", [-1]),
        throwsA(isA<JniException>()));
  });
  // Using printStackTrace from env
  /*
  test("uncommented to print java stack trace", () {
    final r = jni.newInstance("java/util/Random", "()V", []);
    try {
      r.callIntMethodByName("nextInt", "(I)I", [-1]);
    } on JniException catch (e) {
      jni.getEnv().printStackTrace(e);
      // optionally rethrow error
    }
  });
  */
}
