// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

struct CollidingStructName {
};

@interface _Renamed : NSObject
@property int32_t property;
-(NSString*)toString;
-(int32_t)CollidingStructName;
-(int32_t)renamedMethod:(int32_t)x otherArg:(int32_t)y;
@property int32_t renamedProperty;
@end

@implementation _Renamed

// Method with the same name as a Dart built in method.
-(NSString*)toString {
  return [NSString stringWithFormat:@"%d", self.property];
}

// Method with the same name as a type.
-(int32_t)CollidingStructName {
  return 456;
}

// Method that will be renamed.
-(int32_t)renamedMethod:(int32_t)x otherArg:(int32_t)y {
  return x + y;
}

@end
