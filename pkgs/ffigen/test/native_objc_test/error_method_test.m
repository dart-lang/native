// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>
#import <Foundation/NSError.h>

@interface ErrorMethodTestObject : NSObject {}

- (BOOL) errorMethodReturningBool:(BOOL) isOk
                            error:(NSError**) error;
- (nullable NSObject*) errorMethodReturningNullable:(BOOL) isOk
                                              error:(NSError**) error;

@end

@implementation ErrorMethodTestObject

- (BOOL) errorMethodReturningBool:(BOOL) isOk
                            error:(NSError**) error {
  if (!isOk) {
    *error = [NSError errorWithDomain:@"Oh no, an error!"
                      code:123 userInfo:nil];
  }
  return isOk;
}

- (nullable NSObject*) errorMethodReturningNullable:(BOOL) isOk
                                              error:(NSError**) error {
  if (isOk) {
    return [NSObject new];
  } else {
    *error = [NSError errorWithDomain:@"Oh no, another error!"
                      code:123 userInfo:nil];
    return nil;
  }
}

@end
