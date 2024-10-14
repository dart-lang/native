// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

void objc_autoreleasePoolPop(void *pool);
void *objc_autoreleasePoolPush();

@interface ArcTestObject : NSObject {
  int32_t* counter;
}

+ (instancetype)allocTheThing;
+ (instancetype)newWithCounter:(int32_t*) _counter;
- (instancetype)initWithCounter:(int32_t*) _counter;
+ (ArcTestObject*)makeAndAutorelease:(int32_t*) _counter;
- (void)setCounter:(int32_t*) _counter;
- (void)dealloc;
- (ArcTestObject*)copyMe;
- (ArcTestObject*)mutableCopyMe;
- (id)copyWithZone:(NSZone*) zone;
- (ArcTestObject*)returnsRetained NS_RETURNS_RETAINED;
- (ArcTestObject*)copyMeNoRetain __attribute__((ns_returns_not_retained));
- (ArcTestObject*)copyMeAutorelease __attribute__((ns_returns_autoreleased));
- (ArcTestObject*)copyMeConsumeSelf __attribute__((ns_consumes_self));
+ (void)consumeArg:(ArcTestObject*) __attribute((ns_consumed)) arg;

@property (assign) ArcTestObject* assignedProperty;
@property (retain) ArcTestObject* retainedProperty;
@property (copy) ArcTestObject* copiedProperty;

@end

@interface ArcDtorTestObject : NSObject {
  int32_t* dtorCounter;
  int32_t* dtorOnMainThreadCounter;
}
- (instancetype)initWithCounters:(int32_t*) _dtorCounter
    onMainThread: (int32_t*) _dtorOnMainThreadCounter;
@end
