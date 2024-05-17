// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

@interface LogSpamBaseClass : NSObject
+(int32_t)matchingMethod;
+(instancetype)instancetypeMethod;
@end

@implementation LogSpamBaseClass
+(int32_t)matchingMethod {
  return 123;
}

+(id)instancetypeMethod {
  return [LogSpamBaseClass new];
}
@end


@interface LogSpamChildClass : LogSpamBaseClass
+(int32_t)matchingMethod;
+(id)instancetypeMethod;
@end

@implementation LogSpamChildClass
+(int32_t)matchingMethod {
  return 456;
}

+(id)instancetypeMethod {
  return [LogSpamChildClass new];
}
@end
