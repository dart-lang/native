// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

typedef struct {
  int32_t x;
  int32_t y;
} SomeStruct;

@protocol SuperProtocol<NSObject>

@required
- (NSString*)instanceMethod:(NSString*)s withDouble:(double)x;

@end

@protocol MyProtocol<SuperProtocol>

@optional
- (int32_t)optionalMethod:(SomeStruct)s;

@optional
- (void)voidMethod:(int32_t)x;

// Class methods aren't supported in protocol implementation from Dart, but they
// are still codegenned for any native interfaces that implement this protocol.
@required
+ (int32_t)requiredClassMethod;

@optional
+ (int32_t)optionalClassMethod;

@optional
+ (int32_t)unimplementedOtionalClassMethod;

// For https://github.com/dart-lang/native/issues/1702 regression test, disable
// a method (in practice this would be due to API versioning) and verify that
// the protocol builder fails gracefully.
#ifndef DISABLE_METHOD
@optional
- (int32_t)disabledMethod;
#endif

@optional
- (void)intPtrMethod:(int32_t*)ptr;

@end


@protocol SecondaryProtocol<NSObject>

@required
- (int32_t)otherMethod:(int32_t)a b:(int32_t)b c:(int32_t)c d:(int32_t)d;

@optional
- (nullable instancetype)returnsInstanceType;

@end

@protocol EmptyProtocol
@end

@protocol FilteredProtocol
@required
- (int32_t)fooMethod;
@end

@protocol FilteredUnusedProtocol
- (int32_t)filteredUnusedProtocolMethod;
@end


@interface ProtocolConsumer : NSObject
- (NSString*)callInstanceMethod:(id<SuperProtocol>)protocol;
- (int32_t)callOptionalMethod:(id<MyProtocol>)protocol;
- (int32_t)callOtherMethod:(id<SecondaryProtocol>)protocol;
- (void)callMethodOnRandomThread:(id<MyProtocol>)protocol;
- (void)callBlockingMethodOnRandomThread:(id<MyProtocol>)protocol;
- (int32_t)callTwoMethods:(id<MyProtocol, SecondaryProtocol>)protocol;
@end


@interface ObjCProtocolImpl :
    NSObject<MyProtocol, SecondaryProtocol, FilteredProtocol>
@end


@interface ObjCProtocolImplMissingMethod : NSObject<MyProtocol>
@end

@protocol UnusedProtocol<NSObject>
@required
- (int32_t)someMethod;
@end
