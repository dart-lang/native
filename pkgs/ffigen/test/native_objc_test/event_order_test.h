// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSThread.h>

@protocol EventOrderProtocol
@required
- (void) method1:(int32_t)x y:(int8_t)y;
- (void) method2:(int32_t)x y:(int16_t)y;
- (void) method3:(int32_t)x y:(int32_t)y;
- (void) method4:(int32_t)x y:(int64_t)y;
- (void) method5:(int32_t)x y:(uint8_t)y;
- (void) method6:(int32_t)x y:(uint16_t)y;
- (void) method7:(int32_t)x y:(uint32_t)y;
- (void) method8:(int32_t)x y:(uint64_t)y;
- (void) method9:(int32_t)x y:(double)y;
- (void) method10:(int32_t)x y:(float)y;
@end

@interface EventOrderTest {
}

+(void)countTo1000OnNewThread: (id<EventOrderProtocol>) protocol;

@end
