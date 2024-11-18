// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef OBJECTIVE_C_SRC_PROXY_H_
#define OBJECTIVE_C_SRC_PROXY_H_

#import <Foundation/NSProxy.h>

@interface DOBJCDartProxyBuilder : NSObject
+ (instancetype)new;
- (instancetype)init;
- (void)implementMethod:(SEL) sel
        withSignature:(__strong NSMethodSignature *)signature
        andBlock:(void*)block;
@end

@interface DOBJCDartProxy : NSProxy
+ (instancetype)newFromBuilder:(__strong DOBJCDartProxyBuilder*)builder;
- (instancetype)initFromBuilder:(__strong DOBJCDartProxyBuilder*)builder;
- (BOOL)respondsToSelector:(SEL)sel;
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel;
- (void)forwardInvocation:(__strong NSInvocation *)invocation;
@end

#endif  // OBJECTIVE_C_SRC_PROXY_H_
