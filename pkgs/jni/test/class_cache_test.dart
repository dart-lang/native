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
    checkDylibIsUpToDate();
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
}
