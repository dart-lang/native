// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

#include "util.h"

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

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

@implementation ArcTestObject

+ (instancetype)allocTheThing {
  return [ArcTestObject alloc];
}

+ (instancetype)newWithCounter:(int32_t*) _counter {
  return [[ArcTestObject alloc] initWithCounter: _counter];
}

- (instancetype)initWithCounter:(int32_t*) _counter {
  counter = _counter;
  ++*counter;
  return [super init];
}

+ (instancetype)makeAndAutorelease:(int32_t*) _counter {
  return [[ArcTestObject alloc] initWithCounter: _counter];
}

- (void)setCounter:(int32_t*) _counter {
  counter = _counter;
  ++*counter;
}

- (void)dealloc {
  --*counter;
}

- (ArcTestObject*)copyMe {
  return [[ArcTestObject alloc] initWithCounter: counter];
}

- (ArcTestObject*)mutableCopyMe {
  return [[ArcTestObject alloc] initWithCounter: counter];
}

- (id)copyWithZone:(NSZone*) zone {
  return [[ArcTestObject alloc] initWithCounter: counter];
}

- (ArcTestObject*)returnsRetained NS_RETURNS_RETAINED {
  return [self copyMe];
}

- (ArcTestObject*)copyMeNoRetain __attribute__((ns_returns_not_retained)) {
  return [self copyMe];
}

- (ArcTestObject*)copyMeAutorelease __attribute__((ns_returns_autoreleased)) {
  return [self copyMe];
}

- (ArcTestObject*)copyMeConsumeSelf __attribute__((ns_consumes_self)) {
  return [self copyMe];
}

+ (void)consumeArg:(ArcTestObject*) __attribute((ns_consumed)) arg {}

@end
