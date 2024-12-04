// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "event_order_test.h"

@implementation EventOrderTest

+(void)countTo1000OnNewThread:
    (Listener1)listener1
    _: (Listener2)listener2
    _: (Listener3)listener3
    _: (Listener4)listener4
    _: (Listener5)listener5
    _: (Listener6)listener6
    _: (Listener7)listener7
    _: (Listener8)listener8
    _: (Listener9)listener9
    _: (Listener10)listener10 {
  return [[[NSThread alloc] initWithBlock:^{
    for (int32_t i = 0; i < 1000; i += 10) {
      listener1(i + 1, 0);
      listener2(i + 2, 0);
      listener3(i + 3, 0);
      listener4(i + 4, 0);
      listener5(i + 5, 0);
      listener6(i + 6, 0);
      listener7(i + 7, 0);
      listener8(i + 8, 0);
      listener9(i + 9, 0);
      listener10(i + 10, 0);
    }
  }] start];
}

@end
