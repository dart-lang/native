// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "event_order_test.h"

@implementation EventOrderTest

+(void)countTo1000OnNewThread: (id<EventOrderProtocol>) protocol {
  return [[[NSThread alloc] initWithBlock:^{
    for (int32_t i = 0; i < 1000; i += 10) {
      [protocol method1: i + 1 y: 0];
      [protocol method2: i + 2 y: 0];
      [protocol method3: i + 3 y: 0];
      [protocol method4: i + 4 y: 0];
      [protocol method5: i + 5 y: 0];
      [protocol method6: i + 6 y: 0];
      [protocol method7: i + 7 y: 0];
      [protocol method8: i + 8 y: 0];
      [protocol method9: i + 9 y: 0];
      [protocol method10: i + 10 y: 0];
    }
  }] start];
}

@end
