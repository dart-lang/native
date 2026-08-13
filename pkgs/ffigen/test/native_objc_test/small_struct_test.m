// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import "small_struct_test.h"

@implementation SmallStructTester

- (instancetype)init {
  self = [super init];
  if (self) {
    _struct8Property = (Struct8){10};
    _struct16Property = (Struct16){10, 20};
    _struct24Property = (Struct24){10, 20, 30};
    _struct32Property = (Struct32){10, 20, 30, 40};

    _union8Property = (Union8){.a = 10};
    _union16Property = (Union16){.s = (Struct16){10, 20}};
    _union24Property = (Union24){.s = (Struct24){10, 20, 30}};
    _union32Property = (Union32){.s = (Struct32){10, 20, 30, 40}};
  }
  return self;
}

- (Struct8)getStruct8Method {
  return (Struct8){100};
}

- (Struct16)getStruct16Method {
  return (Struct16){100, 200};
}

- (Struct24)getStruct24Method {
  return (Struct24){100, 200, 300};
}

- (Struct32)getStruct32Method {
  return (Struct32){100, 200, 300, 400};
}

- (Union8)getUnion8Method {
  return (Union8){.a = 100};
}

- (Union16)getUnion16Method {
  return (Union16){.s = (Struct16){100, 200}};
}

- (Union24)getUnion24Method {
  return (Union24){.s = (Struct24){100, 200, 300}};
}

- (Union32)getUnion32Method {
  return (Union32){.s = (Struct32){100, 200, 300, 400}};
}

+ (Struct8)callStruct8Block:(Struct8Block)block {
  return block();
}

+ (Struct16)callStruct16Block:(Struct16Block)block {
  return block();
}

+ (Struct24)callStruct24Block:(Struct24Block)block {
  return block();
}

+ (Struct32)callStruct32Block:(Struct32Block)block {
  return block();
}

+ (Union8)callUnion8Block:(Union8Block)block {
  return block();
}

+ (Union16)callUnion16Block:(Union16Block)block {
  return block();
}

+ (Union24)callUnion24Block:(Union24Block)block {
  return block();
}

+ (Union32)callUnion32Block:(Union32Block)block {
  return block();
}

@end
