// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import "category_test.h"

@implementation Thing
-(int32_t)add:(int32_t)x Y:(int32_t) y {
  return x + y;
}

-(int32_t)anonymousCategoryMethod {
  return 404;
}

+(int32_t)anonymousCategoryStaticMethod {
  return 128;
}
@end

@implementation Thing (Sub)
-(int32_t)sub:(int32_t)x Y:(int32_t) y {
  return x - y;
}

+(int32_t)staticMethod {
  return 123;
}
@end

@implementation Thing (Mul)
-(int32_t)mul:(int32_t)x Y:(int32_t) y {
  return x * y;
}

-(int32_t)someProperty {
  return 456;
}
@end

@implementation Thing (CatImplementsProto)
-(int32_t)protoMethod {
  return 987;
}

+(int32_t)staticProtoMethod {
  return 654;
}
@end

@implementation Thing (InstanceTypeCategory)
-(instancetype)instancetypeMethod {
  return [[self class] new];
}
@end

@implementation ChildOfThing
@end

@implementation NSString (InterfaceOnBuiltInType)
-(NSString*)method {
  return [self stringByAppendingString:@"World!"];
}

+(NSString*)staticMethod {
  return @"Goodbye";
}

-(instancetype)instancetypeMethod {
  return [self copy];
}
@end
