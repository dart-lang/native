// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <dispatch/dispatch.h>

#define DISABLE_METHOD 1

#include "protocol_test.h"

const char* class_getName(Class cls);

const char* getClassName(void* cls) {
  return class_getName((__bridge Class)cls);
}

void* getClass(id object) {
  return (__bridge void*)[object class];
}

@implementation ProtocolConsumer : NSObject
- (NSString*)callInstanceMethod:(id<SuperProtocol>)protocol {
  return [protocol instanceMethod:@"Hello from ObjC" withDouble:3.14];
}

- (int32_t)callOptionalMethod:(id<MyProtocol>)protocol {
  if ([protocol respondsToSelector:@selector(optionalMethod:)]) {
    SomeStruct s = {123, 456};
    return [protocol optionalMethod:s];
  } else {
    return -999;
  }
}

- (int32_t)callOtherMethod:(id<SecondaryProtocol>)protocol {
  return [protocol otherMethod:1 b:2 c:3 d:4];
}

- (void)callMethodOnRandomThread:(id<MyProtocol>)protocol {
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
    [protocol voidMethod:123];
  });
}

- (void)callBlockingMethodOnRandomThread:(id<MyProtocol>)protocol {
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
    int32_t x;
    [protocol intPtrMethod:&x];
    [protocol voidMethod:x];
  });
}

- (int32_t)callTwoMethods:(id<MyProtocol, SecondaryProtocol>)protocol {
  SomeStruct s = {123, 345};
  int32_t x = [protocol optionalMethod:s];
  return [protocol otherMethod:x b:1 c:10 d:100];
}
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

- (int32_t)fooMethod {
  return 2468;
}

+ (int32_t)requiredClassMethod {
  return 9876;
}

+ (int32_t)optionalClassMethod {
  return 5432;
}

@end


@implementation ObjCProtocolImplMissingMethod
- (NSString *)instanceMethod:(NSString *)s withDouble:(double)x {
  return @"ObjCProtocolImplMissingMethod";
}
@end
