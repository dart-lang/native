// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

void objc_autoreleasePoolPop(void *pool);
void *objc_autoreleasePoolPush(void);

@interface AutoreleasePoolTestObject : NSObject {
  int32_t *counter;
}

+ (instancetype)newWithCounter:(int32_t *)counter;
- (instancetype)initWithCounter:(int32_t *)counter;
+ (AutoreleasePoolTestObject *)makeAndAutoreleaseWithPool:(int32_t *)counter;
+ (AutoreleasePoolTestObject *)makeAndAutoreleaseWithoutPool:(int32_t *)counter;
- (void)dealloc;

@end

@implementation AutoreleasePoolTestObject

+ (instancetype)newWithCounter:(int32_t *)_counter {
  return [[AutoreleasePoolTestObject alloc] initWithCounter:_counter];
}

- (instancetype)initWithCounter:(int32_t *)_counter {
  self = [super init];
  counter = _counter;
  ++*counter;
  return self;
}

+ (AutoreleasePoolTestObject *)makeAndAutoreleaseWithPool:(int32_t *)_counter {
  return [[AutoreleasePoolTestObject alloc] initWithCounter:_counter];
}

+ (AutoreleasePoolTestObject *)makeAndAutoreleaseWithoutPool:(int32_t *)_counter {
  return [[AutoreleasePoolTestObject alloc] initWithCounter:_counter];
}

- (void)dealloc {
  --*counter;
}

@end
