// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "finalizer_test_subject.h"

FinalizerTestSubject::FinalizerTestSubject(int* _counter) : counter(_counter) {}

FinalizerTestSubject::~FinalizerTestSubject() {
    if (counter != nullptr) {
        (*counter)++;
    }
}
