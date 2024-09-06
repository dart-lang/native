// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

@interface MethodFilteringTestInterface : NSObject {}
+ (instancetype)includedStaticMethod;
+ (instancetype)excludedStaticMethod;
- (instancetype)includedInstanceMethod: (int32_t)arg with: (int32_t)otherArg;
- (instancetype)excludedInstanceMethod: (int32_t)arg with: (int32_t)otherArg;
@property (assign) NSObject* includedProperty;
@property (assign) NSObject* excludedProperty;
@end

@protocol MethodFilteringTestProtocol
- (instancetype)includedProtocolMethod;
- (instancetype)excludedProtocolMethod;
@end
