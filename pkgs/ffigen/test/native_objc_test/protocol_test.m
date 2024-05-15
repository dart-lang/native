// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

typedef struct {
  int32_t x;
  int32_t y;
} SomeStruct;

@protocol MyProtocol<NSObject>

- (NSString*)buildString:(NSString*)s withDouble:(double)x;

@optional
- (int32_t)optionalMethod:(SomeStruct)s;

@end


@interface ProtocolConsumer : NSObject
- (NSString*)getProtoString:(id<MyProtocol>)proto;
- (int32_t)callOptionalMethod:(id<MyProtocol>)proto;
@end

@implementation ProtocolConsumer : NSObject
- (NSString*)getProtoString:(id<MyProtocol>)proto {
  return [proto buildString:@"Hello from ObjC" withDouble:3.14];
}

- (int32_t)callOptionalMethod:(id<MyProtocol>)proto {
  if ([proto respondsToSelector:@selector(optionalMethod:)]) {
    SomeStruct s = {123, 456};
    return [proto optionalMethod:s];
  } else {
    return -999;
  }
}
@end


@interface ObjCProtocolImpl : NSObject<MyProtocol>
@end

@implementation ObjCProtocolImpl
- (NSString *)buildString:(NSString *)s withDouble:(double)x {
  return [NSString stringWithFormat:@"ObjCProtocolImpl: %@: %.2f", s, x];
}

- (int32_t)optionalMethod:(SomeStruct)s {
  return s.x + s.y;
}
@end


@interface ObjCProtocolImplMissingMethod : NSObject<MyProtocol>
@end

@implementation ObjCProtocolImplMissingMethod
- (NSString *)buildString:(NSString *)s withDouble:(double)x {
  return @"ObjCProtocolImplMissingMethod";
}
@end


// TODO(https://github.com/dart-lang/native/issues/1040): Delete these.
typedef NSString* (^BuildStringBlock)(void*, NSString*, double);
void forceCodeGenOfBuildStringBlock(BuildStringBlock block);
typedef int32_t (^OptMethodBlock)(void*, SomeStruct);
void forceCodeGenOfOptMethodBlock(OptMethodBlock block);
