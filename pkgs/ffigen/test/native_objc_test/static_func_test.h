// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

@interface StaticFuncTestObj : NSObject {
  int32_t* counter;
}
+ (instancetype)newWithCounter:(int32_t*) _counter;
- (instancetype)initWithCounter:(int32_t*) _counter;
- (void)dealloc;
@end

StaticFuncTestObj* staticFuncOfObject(StaticFuncTestObj* a);
StaticFuncTestObj* _Nullable staticFuncOfNullableObject(
    StaticFuncTestObj* _Nullable a);

typedef int32_t (^IntBlock)(int32_t);
IntBlock staticFuncOfBlock(IntBlock a);

NS_RETURNS_RETAINED StaticFuncTestObj* staticFuncReturnsRetained(int32_t* counter);
__attribute((ns_returns_retained)) StaticFuncTestObj* staticFuncReturnsRetainedArg(StaticFuncTestObj* a);
void staticFuncConsumesArg(StaticFuncTestObj* __attribute((ns_consumed)) a);

int foo(int x);
int fooPtr(int x);
void *objc_autoreleasePoolPush(void);
void objc_autoreleasePoolPop(void *pool);
