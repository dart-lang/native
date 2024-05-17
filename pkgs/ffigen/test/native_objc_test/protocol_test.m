// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <dispatch/dispatch.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

#include "util.h"

typedef struct {
  int32_t x;
  int32_t y;
} SomeStruct;

@protocol MyProtocol<NSObject>

@required
- (NSString*)instanceMethod:(NSString*)s withDouble:(double)x;

@optional
- (int32_t)optionalMethod:(SomeStruct)s;

@optional
- (void)voidMethod:(int32_t)x;

@end


@protocol SecondaryProtocol<NSObject>

@required
- (int32_t)otherMethod:(int32_t)a b:(int32_t)b c:(int32_t)c d:(int32_t)d;

@end


@interface ProtocolConsumer : NSObject
- (NSString*)callInstanceMethod:(id<MyProtocol>)proto;
- (int32_t)callOptionalMethod:(id<MyProtocol>)proto;
- (int32_t)callOtherMethod:(id<SecondaryProtocol>)proto;
- (void)callMethodOnRandomThread:(id<SecondaryProtocol>)proto;
@end

@implementation ProtocolConsumer : NSObject
- (NSString*)callInstanceMethod:(id<MyProtocol>)proto {
  return [proto instanceMethod:@"Hello from ObjC" withDouble:3.14];
}

- (int32_t)callOptionalMethod:(id<MyProtocol>)proto {
  if ([proto respondsToSelector:@selector(optionalMethod:)]) {
    SomeStruct s = {123, 456};
    return [proto optionalMethod:s];
  } else {
    return -999;
  }
}

- (int32_t)callOtherMethod:(id<SecondaryProtocol>)proto {
  return [proto otherMethod:1 b:2 c:3 d:4];
}

- (void)callMethodOnRandomThread:(id<MyProtocol>)proto {
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
    [proto voidMethod:123];
  });
}
@end


@interface ObjCProtocolImpl : NSObject<MyProtocol, SecondaryProtocol>
@end

@implementation ObjCProtocolImpl
- (NSString *)instanceMethod:(NSString *)s withDouble:(double)x {
  return [NSString stringWithFormat:@"ObjCProtocolImpl: %@: %.2f", s, x];
}

- (int32_t)optionalMethod:(SomeStruct)s {
  return s.x + s.y;
}

- (int32_t)otherMethod:(int32_t)a b:(int32_t)b c:(int32_t)c d:(int32_t)d {
  return a + b + c + d;
}

@end


@interface ObjCProtocolImplMissingMethod : NSObject<MyProtocol>
@end

@implementation ObjCProtocolImplMissingMethod
- (NSString *)instanceMethod:(NSString *)s withDouble:(double)x {
  return @"ObjCProtocolImplMissingMethod";
}
@end


// TODO(https://github.com/dart-lang/native/issues/1040): Delete these.
typedef NSString* (^InstanceMethodBlock)(void*, NSString*, double);
void forceCodeGenOfInstanceMethodBlock(InstanceMethodBlock block);
typedef int32_t (^OptMethodBlock)(void*, SomeStruct);
void forceCodeGenOfOptMethodBlock(OptMethodBlock block);
typedef void (^VoidMethodBlock)(void*, int32_t);
void forceCodeGenOfVoidMethodBlock(VoidMethodBlock block);
typedef int32_t (^OtherMethodBlock)(void*, int32_t a, int32_t b, int32_t c, int32_t d);
void forceCodeGenOfOtherMethodBlock(OtherMethodBlock block);
