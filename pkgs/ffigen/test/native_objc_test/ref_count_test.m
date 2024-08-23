// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>
#import <Foundation/NSAutoreleasePool.h>

#include "util.h"

#if __has_feature(objc_arc)
#error "This file must be compiled with ARC disabled"
#endif

@interface RefCountTestObject : NSObject {
  int32_t* counter;
}

+ (instancetype)allocTheThing;
+ (instancetype)newWithCounter:(int32_t*) _counter;
- (instancetype)initWithCounter:(int32_t*) _counter;
+ (RefCountTestObject*)makeAndAutorelease:(int32_t*) _counter;
- (void)setCounter:(int32_t*) _counter;
- (void)dealloc;
- (RefCountTestObject*)unownedReference;
- (RefCountTestObject*)copyMe;
- (RefCountTestObject*)makeACopy;
- (id)copyWithZone:(NSZone*) zone;
- (RefCountTestObject*)returnsRetained NS_RETURNS_RETAINED;

@property (assign) RefCountTestObject* assignedProperty;
@property (retain) RefCountTestObject* retainedProperty;
@property (copy) RefCountTestObject* copiedProperty;

@end

@interface RefCounted : NSObject

@property(readonly) uint64_t refCount;

- (int64_t) meAsInt;

@end

@implementation RefCountTestObject

+ (instancetype)allocTheThing {
  return [RefCountTestObject alloc];
}

+ (instancetype)newWithCounter:(int32_t*) _counter {
  return [[RefCountTestObject alloc] initWithCounter: _counter];
}

- (instancetype)initWithCounter:(int32_t*) _counter {
  counter = _counter;
  ++*counter;
  return [super init];
}

+ (instancetype)makeAndAutorelease:(int32_t*) _counter {
  return [[[RefCountTestObject alloc] initWithCounter: _counter] autorelease];
}

- (void)setCounter:(int32_t*) _counter {
  counter = _counter;
  ++*counter;
}

- (void)dealloc {
  --*counter;
  [_retainedProperty release];
  [_copiedProperty release];
  [super dealloc];
}

- (RefCountTestObject*)unownedReference {
  return self;
}

- (RefCountTestObject*)copyMe {
  return [[RefCountTestObject alloc] initWithCounter: counter];
}

- (RefCountTestObject*)makeACopy {
  return [[RefCountTestObject alloc] initWithCounter: counter];
}

- (id)copyWithZone:(NSZone*) zone {
  return [[RefCountTestObject alloc] initWithCounter: counter];
}

- (RefCountTestObject*)returnsRetained NS_RETURNS_RETAINED {
  return [self retain];
}

@end

// Pass around the NSAutoreleasePool as a void* to bypass the Dart wrappers so
// that we can precisely control the life cycle.
void* createAutoreleasePool() {
  return (void*)[NSAutoreleasePool new];
}

void destroyAutoreleasePool(void* pool) {
  [((NSAutoreleasePool*)pool) release];
}

@implementation RefCounted

- (instancetype)init {
    if (self = [super init]) {
      self->_refCount = 1;
    }
    return self;
}

- (instancetype)retain {
  ++self->_refCount;
  return self;
}

- (oneway void)release {
  --self->_refCount;
  if (self->_refCount == 0) {
    [self dealloc];
  }
}

- (int64_t) meAsInt {
  return (int64_t) self;
}

@end
