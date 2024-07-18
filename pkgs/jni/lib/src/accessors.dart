// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import '../jni.dart';

void _check(JThrowablePtr exception) {
  if (exception != nullptr) {
    Jni.throwException(exception);
  }
}

extension JniResultMethods on JniResult {
  void check() => _check(exception);

  int get byte {
    check();
    return value.b;
  }

  int get short {
    check();
    return value.s;
  }

  int get char {
    check();
    return value.c;
  }

  int get integer {
    check();
    return value.i;
  }

  int get long {
    check();
    return value.j;
  }

  double get float {
    check();
    return value.f;
  }

  double get doubleFloat {
    check();
    return value.d;
  }

  JObjectPtr get objectPointer {
    check();
    return value.l;
  }

  JReference get reference {
    return JGlobalReference(objectPointer);
  }

  T object<T extends JObject>(JObjType<T> type) {
    return type.fromReference(reference);
  }

  bool get boolean {
    check();
    return value.z != 0;
  }
}

extension JniIdLookupResultMethods on JniPointerResult {
  JMethodIDPtr get methodID {
    _check(exception);
    return value.cast<jmethodID_>();
  }

  JFieldIDPtr get fieldID {
    _check(exception);
    return value.cast<jfieldID_>();
  }

  Pointer<Void> get checkedRef {
    _check(exception);
    return value;
  }

  Pointer<T> getPointer<T extends NativeType>() {
    return value.cast<T>();
  }
}

extension JniClassLookupResultMethods on JniClassLookupResult {
  JClassPtr get checkedClassRef {
    _check(exception);
    return value;
  }
}

extension JThrowableCheckMethod on JThrowablePtr {
  void check() {
    _check(this);
  }
}
