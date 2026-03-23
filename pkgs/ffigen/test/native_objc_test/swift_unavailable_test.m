// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

#define SWIFT_UNAVAILABLE \
  __attribute__((availability(swift, unavailable)))
#define SWIFT_UNAVAILABLE_MSG(msg) \
  __attribute__((availability(swift, unavailable, message = msg)))
#define OBJC_DESIGNATED_INITIALIZER \
  __attribute__((objc_designated_initializer))

@interface Animal : NSObject
@property(nonatomic, copy) NSString* _Nonnull name;
- (nonnull instancetype)initWithName:(NSString* _Nonnull)name
    OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_UNAVAILABLE_MSG("-init is unavailable");
@end
