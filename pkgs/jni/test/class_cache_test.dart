// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Tags(['load_test'])
library;

import 'dart:ffi';
import 'dart:io';

import 'package:jni/jni.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void main() {
  if (!Platform.isAndroid) {
    spawnJvm();
  }
  run(testRunner: test);
}

void run({required TestRunnerCallback testRunner}) {
  testRunner('Basic cache functionality', () {
    final stringClass = Jni.getCachedClass('java/lang/String');
    expect(stringClass, isNotNull);

    final stringClass2 = Jni.getCachedClass('java/lang/String');
    expect(stringClass2, isNotNull);
    // Same cached instance
    expect(identical(stringClass, stringClass2), isTrue);

    // Check JNI equality (should be same object)
    expect(
        Jni.env.IsSameObject(
            stringClass.reference.pointer, stringClass2.reference.pointer),
        isTrue);
  });

  testRunner('Cache capacity configuration', () {
    // Set small capacity
    Jni.setClassCacheSize(2);

    final c1 = Jni.getCachedClass('java/lang/String');
    final c2 = Jni.getCachedClass('java/util/ArrayList');
    // c3 evicts c1
    final c3 = Jni.getCachedClass('java/util/HashMap');

    // c2 and c3 still cached
    expect(c2, isNotNull);
    expect(c3, isNotNull);

    // Reload c1 (was evicted, creates new cached instance)
    final c1Reload = Jni.getCachedClass('java/lang/String');
    // c1Reload is a different Dart instance since eviction recreated it
    expect(identical(c1, c1Reload), isFalse);
  });

  testRunner('Stress test cache', () {
    Jni.setClassCacheSize(100);
    final classes = [
      'java/lang/Byte',
      'java/lang/Short',
      'java/lang/Integer',
      'java/lang/Long',
      'java/lang/Float',
      'java/lang/Double',
      'java/lang/Boolean',
      'java/lang/Character',
      'java/lang/Object',
      'java/lang/Class',
      'java/lang/Number',
      'java/util/List',
      'java/util/Map',
      'java/util/Set',
      'java/util/Collection',
      'java/util/Iterator',
      'java/util/Random',
      'java/io/File',
      'java/io/InputStream',
      'java/io/OutputStream',
    ];

    for (var i = 0; i < 1000; i++) {
      final name = classes[i % classes.length];
      final cls = Jni.getCachedClass(name);
      expect(cls, isNotNull);
    }
  });

  testRunner('Cache hit returns same instance', () {
    final c1 = Jni.getCachedClass('java/lang/Object');
    final c2 = Jni.getCachedClass('java/lang/Object');
    // Both are the same cached instance
    expect(identical(c1, c2), isTrue);
    // Same underlying JNI object
    expect(
        Jni.env.IsSameObject(
            c1.reference.pointer, c2.reference.pointer),
        isTrue);
  });

  testRunner('Eviction and reload', () {
    Jni.setClassCacheSize(2);

    final _name1 = 'java/lang/String';
    final _name2 = 'java/lang/Integer';
    final _name3 = 'java/lang/Double';

    final ref1 = Jni.getCachedClass(_name1);
    final ref2 = Jni.getCachedClass(_name2);

    // Insert third class, evicting String (LRU)
    final ref3 = Jni.getCachedClass(_name3);

    // ref2 and ref3 still cached and valid
    expect(ref2, isNotNull);
    expect(ref3, isNotNull);

    // String evicted; reload creates new cached instance
    final ref1Reload = Jni.getCachedClass(_name1);
    // Not identical since eviction recreated it
    expect(identical(ref1, ref1Reload), isFalse);
  });

  testRunner('Capacity reduction evicts entries', () {
    Jni.setClassCacheSize(10);

    final refs = <JClass>[];
    final uniqueClasses = [
      'java/lang/String',
      'java/lang/Integer',
      'java/lang/Double',
      'java/lang/Boolean',
      'java/lang/Long',
      'java/lang/Float',
      'java/lang/Byte',
      'java/lang/Short',
      'java/lang/Character',
      'java/util/ArrayList',
    ];

    for (final className in uniqueClasses) {
      refs.add(Jni.getCachedClass(className));
    }

    // Reduce capacity - cache evicts 7 entries
    Jni.setClassCacheSize(3);

    // All cached instances should still be valid
    for (final ref in refs) {
      expect(ref, isNotNull);
    }
  });

  testRunner('JClass.forNameCached uses cache and returns same instance', () {
    final jclass1 = JClass.forNameCached('java/lang/Object');
    final jclass2 = JClass.forNameCached('java/lang/Object');

    // Same Dart instance from cache
    expect(identical(jclass1, jclass2), isTrue);

    // Same underlying JNI class
    final ref1 = jclass1.reference;
    final ref2 = jclass2.reference;
    expect(Jni.env.IsSameObject(ref1.pointer, ref2.pointer), isTrue);

    // Do NOT release cached instances - cache owns them
  });
}
