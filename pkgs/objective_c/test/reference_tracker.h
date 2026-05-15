// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef OBJECTIVE_C_TEST_REFERENCE_TRACKER_H_
#define OBJECTIVE_C_TEST_REFERENCE_TRACKER_H_

#include <stdbool.h>

void attachReferenceTracker(id host, bool* isAlive);

#endif  // OBJECTIVE_C_TEST_REFERENCE_TRACKER_H_
