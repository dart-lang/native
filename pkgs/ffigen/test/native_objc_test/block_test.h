// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSThread.h>

void objc_autoreleasePoolPop(void *pool);
void *objc_autoreleasePoolPush();

struct Vec2 {
  double x;
  double y;
};

typedef struct {
  double x;
  double y;
  double z;
  double w;
} Vec4;

@interface DummyObject : NSObject {
  int32_t* counter;
}
+ (instancetype)newWithCounter:(int32_t*)_counter;
- (instancetype)initWithCounter:(int32_t*)_counter;
- (void)setCounter:(int32_t*)_counter;
- (void)dealloc;
@end

typedef int32_t (^IntBlock)(int32_t);
typedef float (^FloatBlock)(float);
typedef double (^DoubleBlock)(double);
typedef Vec4 (^Vec4Block)(Vec4);
typedef void (^VoidBlock)();
typedef DummyObject* (^ObjectBlock)(DummyObject*);
typedef DummyObject* _Nullable (^NullableObjectBlock)(DummyObject* _Nullable);
typedef NSString* _Nullable (^NullableStringBlock)(NSString* _Nullable);
typedef IntBlock (^BlockBlock)(IntBlock);
typedef void (^ListenerBlock)(IntBlock);
typedef void (^ObjectListenerBlock)(DummyObject*);
typedef void (^NullableListenerBlock)(DummyObject* _Nullable);
typedef void (^StructListenerBlock)(struct Vec2, Vec4, NSObject*);
typedef void (^NSStringListenerBlock)(NSString*);
typedef void (^NoTrampolineListenerBlock)(int32_t, Vec4, const char*);

// Wrapper around a block, so that our Dart code can test creating and invoking
// blocks in Objective C code.
@interface BlockTester : NSObject {
  __strong IntBlock myBlock;
  __strong ObjectListenerBlock myListener;
}
+ (BlockTester*)newFromBlock:(IntBlock)block;
+ (BlockTester*)newFromMultiplier:(int32_t)mult;
+ (BlockTester*)newFromListener:(ObjectListenerBlock)block;
- (int32_t)call:(int32_t)x;
- (IntBlock)getBlock NS_RETURNS_RETAINED;
- (void)pokeBlock;
+ (void)callOnSameThread:(VoidBlock)block;
+ (NSThread*)callOnNewThread:(VoidBlock)block NS_RETURNS_RETAINED;
+ (NSThread*)callWithBlockOnNewThread:(ListenerBlock)block NS_RETURNS_RETAINED;
+ (float)callFloatBlock:(FloatBlock)block;
+ (double)callDoubleBlock:(DoubleBlock)block;
+ (Vec4)callVec4Block:(Vec4Block)block;
+ (DummyObject*)callObjectBlock:(ObjectBlock)block NS_RETURNS_RETAINED;
+ (nullable DummyObject*)callNullableObjectBlock:(NullableObjectBlock)block
    NS_RETURNS_RETAINED;
+ (nullable NSString*)callNullableStringBlock:(NullableStringBlock)block
    NS_RETURNS_RETAINED;
+ (void)callListener:(ListenerBlock)block;
+ (void)callObjectListener:(ObjectListenerBlock)block;
+ (void)callNullableListener:(NullableListenerBlock)block;
+ (void)callStructListener:(StructListenerBlock)block;
+ (void)callNSStringListener:(NSStringListenerBlock)block x:(int32_t)x;
+ (void)callNoTrampolineListener:(NoTrampolineListenerBlock)block;
+ (IntBlock)newBlock:(BlockBlock)block withMult:(int)mult NS_RETURNS_RETAINED;
+ (BlockBlock)newBlockBlock:(int)mult NS_RETURNS_RETAINED;
- (void)invokeAndReleaseListenerOnNewThread;
- (void)invokeAndReleaseListener:(id)_;
@end
