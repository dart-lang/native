// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

typedef struct {} Struct0;

typedef struct {
  int64_t a;
} Struct8;

typedef struct {
  int64_t a;
  int64_t b;
} Struct16;

typedef struct {
  int64_t a;
  int64_t b;
  int64_t c;
} Struct24;

typedef struct {
  int64_t a;
  int64_t b;
  int64_t c;
  int64_t d;
} Struct32;

typedef Struct8 (^Struct8Block)(void);
typedef Struct16 (^Struct16Block)(void);
typedef Struct24 (^Struct24Block)(void);
typedef Struct32 (^Struct32Block)(void);

@interface SmallStructTester : NSObject

@property Struct8 struct8Property;
@property Struct16 struct16Property;
@property Struct24 struct24Property;
@property Struct32 struct32Property;

- (Struct8)getStruct8Method;
- (Struct16)getStruct16Method;
- (Struct24)getStruct24Method;
- (Struct32)getStruct32Method;

+ (Struct8)callStruct8Block:(Struct8Block)block;
+ (Struct16)callStruct16Block:(Struct16Block)block;
+ (Struct24)callStruct24Block:(Struct24Block)block;
+ (Struct32)callStruct32Block:(Struct32Block)block;

@end
