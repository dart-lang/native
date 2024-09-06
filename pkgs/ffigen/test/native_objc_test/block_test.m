// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>

#include "block_test.h"
#include "util.h"

@implementation DummyObject

+ (instancetype)newWithCounter:(int32_t*)_counter {
  return [[DummyObject alloc] initWithCounter:_counter];
}

- (instancetype)initWithCounter:(int32_t*)_counter {
  counter = _counter;
  ++*counter;
  return [super init];
}

- (void)setCounter:(int32_t*)_counter {
  counter = _counter;
  ++*counter;
}

- (void)dealloc {
  if (counter != nil) --*counter;
}

@end

@implementation BlockTester

+ (BlockTester*)newFromBlock:(IntBlock)block {
  BlockTester* bt = [BlockTester new];
  bt->myBlock = block;
  return bt;
}

+ (BlockTester*)newFromMultiplier:(int32_t)mult {
  BlockTester* bt = [BlockTester new];
  bt->myBlock = [^int32_t(int32_t x) {
    return x * mult;
  } copy];
  return bt;
}

- (int32_t)call:(int32_t)x {
  return myBlock(x);
}

- (IntBlock)getBlock NS_RETURNS_RETAINED {
  return myBlock;
}

id objc_retain(id value);
void objc_release(id value);
- (void)pokeBlock {
  // Used to repro https://github.com/dart-lang/ffigen/issues/376
  objc_release(objc_retain(myBlock));
}

+ (void)callOnSameThread:(VoidBlock)block {
  block();
}

+ (NSThread*)callOnNewThread:(VoidBlock)block NS_RETURNS_RETAINED {
  return [[NSThread alloc] initWithBlock:block];
}

+ (void)callListener:(ListenerBlock)block {
  // Note: This method is invoked on a background thread.

  // This multiplier is defined in a bound variable rather than inside the block
  // to force the compiler to make a real lambda style block. Without this, we
  // get a _NSConcreteGlobalBlock (essentially a static function pointer), which
  // always has a ref count of 0, so we can't test the ref counting.
  int mult = 100;

  block(^int(int x) {
    return mult * x;
  });
}

+ (NSThread*)callWithBlockOnNewThread:(ListenerBlock)block NS_RETURNS_RETAINED {
  return [[NSThread alloc] initWithTarget:[BlockTester class]
                                 selector:@selector(callListener:)
                                   object:block];
}

+ (void)callObjectListener:(ObjectListenerBlock)block {
  block([DummyObject alloc]);
}

+ (void)callNullableListener:(NullableListenerBlock)block {
  block(nil);
}

+ (void)callStructListener:(StructListenerBlock)block {
  struct Vec2 vec2;
  vec2.x = 100;
  vec2.y = 200;

  Vec4 vec4;
  vec4.x = 1.2;
  vec4.y = 3.4;
  vec4.z = 5.6;
  vec4.w = 7.8;

  // We're interested in testing how structs pass through the native
  // trampolines, but a native trampoline will only be generated if there are
  // ref counted objects being passed too. So pass a dummy NSObject.
  NSObject* dummy = [NSObject new];

  block(vec2, vec4, dummy);
}

+ (void)callNSStringListener:(NSStringListenerBlock)block x:(int32_t)x {
  block([NSString stringWithFormat:@"Foo %d", x]);
}

+ (void)callNoTrampolineListener:(NoTrampolineListenerBlock)block {
  Vec4 vec4;
  vec4.x = 1.2;
  vec4.y = 3.4;
  vec4.z = 5.6;
  vec4.w = 7.8;
  block(123, vec4, "Hello World");
}

+ (float)callFloatBlock:(FloatBlock)block {
  return block(1.23);
}

+ (double)callDoubleBlock:(DoubleBlock)block {
  return block(1.23);
}

+ (Vec4)callVec4Block:(Vec4Block)block {
  Vec4 vec4;
  vec4.x = 1.2;
  vec4.y = 3.4;
  vec4.z = 5.6;
  vec4.w = 7.8;
  return block(vec4);
}

+ (DummyObject*)callObjectBlock:(ObjectBlock)block NS_RETURNS_RETAINED {
  return block([DummyObject new]);
}

+ (nullable DummyObject*)callNullableObjectBlock:(NullableObjectBlock)block
    NS_RETURNS_RETAINED {
  return block(nil);
}

+ (IntBlock)newBlock:(BlockBlock)block withMult:(int)mult NS_RETURNS_RETAINED {
  IntBlock inputBlock = ^int(int x) {
    return mult * x;
  };
  return block(inputBlock);
}

+ (BlockBlock)newBlockBlock:(int)mult NS_RETURNS_RETAINED {
  return ^IntBlock(IntBlock block) {
    return ^int(int x) {
      return mult * block(x);
    };
  };
}

@end
