// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef OBJECTIVE_C_SRC_PROXY_H_
#define OBJECTIVE_C_SRC_PROXY_H_

#import <Foundation/NSProxy.h>

@interface DartProxyBuilder : NSObject
+ (instancetype)new;
- (instancetype)init;
- (void)implementMethod:(SEL) sel
        withSignature:(NSMethodSignature *)signature
        andBlock:(void *)block;
@end

@interface DartProxy : NSProxy
+ (instancetype)newFromBuilder:(DartProxyBuilder*)builder;
- (instancetype)initFromBuilder:(DartProxyBuilder*)builder;
- (BOOL)respondsToSelector:(SEL)sel;
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel;
- (void)forwardInvocation:(NSInvocation *)invocation;
@end

#endif  // OBJECTIVE_C_SRC_PROXY_H_
