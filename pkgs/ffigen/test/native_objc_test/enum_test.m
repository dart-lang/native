// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSArray.h>
#import <Foundation/NSObject.h>

typedef NS_ENUM(NSInteger, Fruit) {
    FruitApple,
    FruitBanana,
    FruitOrange,
    FruitPear,
};

typedef NS_OPTIONS(NSUInteger, CoffeeOptions) {
    CoffeeOptionsNone  = 0,
    CoffeeOptionsMilk  = 1 << 0,
    CoffeeOptionsSugar = 1 << 1,
    CoffeeOptionsIced  = 1 << 2,
};

@interface EnumTestInterface : NSObject {}

+(int32_t)useImportedNSEnum:(NSQualityOfService)x;
+(int32_t)useImportedNSOptions:
    (NSOrderedCollectionDifferenceCalculationOptions)x;

@end

@implementation EnumTestInterface

+(int32_t)useImportedNSEnum:(NSQualityOfService)x {
  return (int32_t)x;
}

+(int32_t)useImportedNSOptions:
    (NSOrderedCollectionDifferenceCalculationOptions)x {
  return (int32_t)x;
}

@end
