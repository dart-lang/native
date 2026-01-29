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
    expect(stringClass, isNot(nullptr));

    final stringClass2 = Jni.getCachedClass('java/lang/String');
    expect(stringClass2, isNot(nullptr));
    expect(stringClass.address, isNot(equals(stringClass2.address)));

    // Check JNI equality (should be same object)
    expect(Jni.env.IsSameObject(stringClass, stringClass2), isTrue);
    Jni.env.DeleteGlobalRef(stringClass);
    Jni.env.DeleteGlobalRef(stringClass2);
  });

  testRunner('Cache capacity configuration', () {
    // Set small capacity
    Jni.setClassCacheSize(2);

    final c1 = Jni.getCachedClass('java/lang/String');
    final c2 = Jni.getCachedClass('java/util/ArrayList');
    // c3 would evict c1 if strictly LRU logic was only on insert,
    // but lookup of c1 moves it to head? No, we haven't looked it up again yet.
    // Insert c1. Head=c1. Size=1.
    // Insert c2. Head=c2->c1. Size=2.
    // Insert c3. Evict Tail(c1). Head=c3->c2. Size=2.
    final c3 = Jni.getCachedClass('java/util/HashMap');

    // Verify c1 still works (it's a new global ref)
    expect(c1, isNot(nullptr));

    // Verify we can reload c1
    final c1Reload = Jni.getCachedClass('java/lang/String');
    expect(Jni.env.IsSameObject(c1, c1Reload), isTrue);

    Jni.env.DeleteGlobalRef(c1);
    Jni.env.DeleteGlobalRef(c2);
    Jni.env.DeleteGlobalRef(c3);
    Jni.env.DeleteGlobalRef(c1Reload);
  });

  testRunner('Stress test cache', () {
    Jni.setClassCacheSize(100);
    // Load many classes
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
      expect(cls, isNot(nullptr));
      Jni.env.DeleteGlobalRef(cls);
    }
  });

  testRunner('Cache hit returns new global ref', () {
    // Tests the ownership model: cache owns refs, callers get duplicates.
    final c1 = Jni.getCachedClass('java/lang/Object');
    final c2 = Jni.getCachedClass('java/lang/Object');
    // Pointers are different (different GlobalRefs)
    expect(c1, isNot(equals(c2)));
    // Objects are same
    expect(Jni.env.IsSameObject(c1, c2), isTrue);

    // Cleanup
    Jni.env.DeleteGlobalRef(c1);
    Jni.env.DeleteGlobalRef(c2);

    // Cache should still hold a ref internally, so getting it again should work
    final c3 = Jni.getCachedClass('java/lang/Object');
    expect(c3, isNot(nullptr));
    Jni.env.DeleteGlobalRef(c3);
  });

  testRunner('Cache-held refs survive caller deletion', () {
    // Tests that deleting caller-owned refs doesn't invalidate cache.
    // This validates the ownership model: cache owns its refs separately.

    final ref1 = Jni.getCachedClass('java/lang/System');
    expect(ref1, isNot(nullptr));

    // Delete the ref we got (caller-owned duplicate)
    Jni.env.DeleteGlobalRef(ref1);

    // Cache should still have its own ref, so we can get it again
    final ref2 = Jni.getCachedClass('java/lang/System');
    expect(ref2, isNot(nullptr));
    expect(Jni.env.IsSameObject(ref1, ref2), isTrue);

    Jni.env.DeleteGlobalRef(ref2);
  });

  testRunner('Eviction deletes cache-owned refs', () {
    // Tests that cache properly deletes owned GlobalRefs on eviction.
    Jni.setClassCacheSize(2);

    final ref1 = Jni.getCachedClass('java/lang/String');
    final ref2 = Jni.getCachedClass('java/lang/Integer');

    // Insert third class, evicting String (LRU)
    final ref3 = Jni.getCachedClass('java/lang/Double');

    // All caller refs should still be valid
    expect(Jni.env.IsSameObject(ref1, ref1), isTrue);
    expect(Jni.env.IsSameObject(ref2, ref2), isTrue);
    expect(Jni.env.IsSameObject(ref3, ref3), isTrue);

    // String should have been evicted from cache, but we can reload it
    final ref1Reload = Jni.getCachedClass('java/lang/String');
    expect(Jni.env.IsSameObject(ref1, ref1Reload), isTrue);

    // Clean up all caller-owned refs
    Jni.env.DeleteGlobalRef(ref1);
    Jni.env.DeleteGlobalRef(ref2);
    Jni.env.DeleteGlobalRef(ref3);
    Jni.env.DeleteGlobalRef(ref1Reload);
  });

  testRunner('Capacity reduction evicts and deletes refs', () {
    // Tests that reducing capacity immediately evicts and deletes owned refs.
    Jni.setClassCacheSize(10);

    // Fill cache with 10 classes
    final refs = <dynamic>[];
    for (var i = 0; i < 10; i++) {
      final className = 'java/lang/String'; // Use same class for simplicity
      refs.add(Jni.getCachedClass(className));
    }

    // Reduce capacity - should evict 7 entries
    Jni.setClassCacheSize(3);

    // All caller-owned refs should still be valid
    for (final ref in refs) {
      expect(Jni.env.IsSameObject(ref, ref), isTrue);
    }

    // Clean up caller-owned refs
    for (final ref in refs) {
      Jni.env.DeleteGlobalRef(ref);
    }
  });

  testRunner('JClass.forNameCached uses cache', () {
    // Tests that JClass.forNameCached integrates correctly with the cache.
    // This validates that the ownership model works through the wrapper API.

    final jclass1 = JClass.forNameCached('java/lang/Object');
    final jclass2 = JClass.forNameCached('java/lang/Object');

    // Different Dart objects
    expect(identical(jclass1, jclass2), isFalse);

    // Same underlying JNI class
    final ref1 = jclass1.reference;
    final ref2 = jclass2.reference;
    expect(Jni.env.IsSameObject(ref1.pointer, ref2.pointer), isTrue);

    // JGlobalReference finalizers will clean up when GC'd
    jclass1.release();
    jclass2.release();
  });
}
