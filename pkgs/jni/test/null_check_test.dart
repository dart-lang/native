// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:jni/jni.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void main() {
  run(testRunner: test);
}

void run({required TestRunnerCallback testRunner}) {
  testRunner('Null object reference is handled gracefully', () {
    // Using the null reference directly should not crash when calling methods
    final randomClass = JClass.forName('java/util/Random');
    final methodId = randomClass.instanceMethodId('nextInt', '(I)I');
    
    // Attempt to call method on null object should throw an exception, not crash
    expect(
      () => methodId.call(
        JObject.fromReference(jNullReference),
        jint.type,
        [JValueInt(100)],
      ),
      throwsA(isA<JniException>()),
    );
  });

  testRunner('Null class reference is handled gracefully', () {
    // Create a null class reference
    final nullClassRef = JClass.fromReference(jNullReference);
    
    // Attempting to get a method ID from null class should throw
    expect(
      () => nullClassRef.instanceMethodId('nextInt', '(I)I'),
      throwsA(isA<JniException>()),
    );
  });

  testRunner('Valid references still work correctly', () {
    // Ensure our null checks don't break normal operation
    final randomClass = JClass.forName('java/util/Random');
    final random = randomClass.constructorId('()V').call(
      randomClass,
      JObject.type,
      [],
    );
    
    final methodId = randomClass.instanceMethodId('nextInt', '(I)I');
    final result = methodId.call(random, jint.type, [JValueInt(100)]);
    
    expect(result, isA<int>());
    expect(result, greaterThanOrEqualTo(0));
    expect(result, lessThan(100));
    
    random.release();
  });

  testRunner('Null checks apply to field access', () {
    // Test with a class that has fields
    final integerClass = JClass.forName('java/lang/Integer');
    final maxValueField = integerClass.staticFieldId('MAX_VALUE', 'I');
    
    final maxValue = maxValueField.get(integerClass, jint.type);
    expect(maxValue, equals(2147483647));
    
    final nullClassRef = JClass.fromReference(jNullReference);
    expect(
      () => maxValueField.get(nullClassRef, jint.type),
      throwsA(isA<JniException>()),
    );
  });

  testRunner('Null checks work for constructor calls', () {
    final integerClass = JClass.forName('java/lang/Integer');
    final ctorId = integerClass.constructorId('(I)V');
    
    // Valid constructor call should work
    final integer = ctorId.call(
      integerClass,
      JObject.type,
      [JValueInt(42)],
    );
    expect(integer, isNotNull);
    integer.release();
    
    // Null class reference for constructor should be handled
    final nullClassRef = JClass.fromReference(jNullReference);
    expect(
      () => ctorId.call(nullClassRef, JObject.type, [JValueInt(42)]),
      throwsA(isA<JniException>()),
    );
  });

  testRunner('Null-safe functions like DeleteGlobalRef handle null', () {
    expect(
      () => Jni.env.DeleteGlobalRef(nullptr),
      returnsNormally,
    );
  });

  testRunner('IsSameObject handles null references correctly', () {
    final randomClass = JClass.forName('java/util/Random');
    final random = randomClass.constructorId('()V').call(
      randomClass,
      JObject.type,
      [],
    );
    
    final isSame1 = Jni.env.IsSameObject(random.reference.pointer, nullptr);
    expect(isSame1, equals(0)); // false
    
    final isSame2 = Jni.env.IsSameObject(nullptr, nullptr);
    expect(isSame2, equals(1)); // true
    
    random.release();
  });
}
