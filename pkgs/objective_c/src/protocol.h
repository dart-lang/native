// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef OBJECTIVE_C_SRC_PROXY_H_
#define OBJECTIVE_C_SRC_PROXY_H_

#import <Foundation/NSObject.h>

#include "include/dart_api_dl.h"

@interface DOBJCDartProtocolBuilder : NSObject
+ (instancetype)new;
- (instancetype)init;
- (void)implementMethod:(SEL) sel withBlock:(void*)block;
@end

@interface DOBJCDartProtocol : NSObject
- (instancetype)initDOBJCDartProtocolFromDartProtocolBuilder:
    (DOBJCDartProtocolBuilder*)builder
    withDisposePort:(Dart_Port)port;
- (id)getDOBJCDartProtocolMethodForSelector:(SEL)sel;
- (void)dealloc;
@end

#endif  // OBJECTIVE_C_SRC_PROXY_H_
