// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

@interface Thing : NSObject {}
-(int32_t)add:(int32_t)x Y:(int32_t) y;
@end

@interface Thing (Sub)
-(int32_t)sub:(int32_t)x Y:(int32_t) y;
+(int32_t)staticMethod;
@end

@interface Thing (Mul)
-(int32_t)mul:(int32_t)x Y:(int32_t) y;

@property (readonly) int32_t someProperty;
@end

@protocol CatTestProtocol<NSObject>
-(int32_t)protoMethod;
+(int32_t)staticProtoMethod;
@end

@interface Thing (CatImplementsProto) <CatTestProtocol>
@end

@interface Thing (InstanceTypeCategory)
-(instancetype)instancetypeMethod;
@end

@interface ChildOfThing : Thing {}
@end

@interface NSString (InterfaceOnBuiltInType)
-(NSString*)method;
+(NSString*)staticMethod;
-(instancetype)instancetypeMethod;
@end
