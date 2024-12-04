// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSThread.h>

// 10 listeners with different signatures. Only the first arg is actually used
// in this test.
typedef void (^Listener1)(int32_t, int8_t);
typedef void (^Listener2)(int32_t, int16_t);
typedef void (^Listener3)(int32_t, int32_t);
typedef void (^Listener4)(int32_t, int64_t);
typedef void (^Listener5)(int32_t, uint8_t);
typedef void (^Listener6)(int32_t, uint16_t);
typedef void (^Listener7)(int32_t, uint32_t);
typedef void (^Listener8)(int32_t, uint64_t);
typedef void (^Listener9)(int32_t, double);
typedef void (^Listener10)(int32_t, float);

@interface EventOrderTest {
}

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
    _: (Listener10)listener10;

@end
