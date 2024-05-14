// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

@protocol MyProtocol
- (NSString*)buildString:(NSString*)s withDouble:(double)x;
@end

@interface ProtocolConsumer : NSObject
- (NSString*)getProtoString:(id<MyProtocol>)proto;
@end

@implementation ProtocolConsumer : NSObject
- (NSString*)getProtoString:(id<MyProtocol>)proto {
  return [proto buildString:@"Hello from ObjC" withDouble:3.14];
}
@end

@interface ObjCProtocolImpl : NSObject<MyProtocol>
@end

@implementation ObjCProtocolImpl
- (NSString *)buildString:(NSString *)s withDouble:(double)x {
  return [NSString stringWithFormat:@"ObjCProtocolImpl: %@: %.2f", s, x];
}
@end

// TODO(https://github.com/dart-lang/native/issues/1040): Delete this.
typedef NSString* (^BuildStringBlock)(void*, NSString*, double);

// TODO(https://github.com/dart-lang/native/issues/1040): Delete this.
void forceCodeGenOfBuildStringBlock(BuildStringBlock block);
