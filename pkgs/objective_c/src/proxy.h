// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef OBJECTIVE_C_SRC_PROXY_H_
#define OBJECTIVE_C_SRC_PROXY_H_

#import <Foundation/NSDictionary.h>
#import <Foundation/NSProxy.h>

@interface DartProxy : NSProxy
@property(retain) NSMutableDictionary *methods;
+ (instancetype)new;
- (instancetype)init;
- (void)implementMethod:(SEL) sel
        withSignature:(NSMethodSignature *)signature
        andBlock:(void *)block;
- (BOOL)respondsToSelector:(SEL)sel;
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel;
- (void)forwardInvocation:(NSInvocation *)invocation;
@end

#endif  // OBJECTIVE_C_SRC_PROXY_H_
