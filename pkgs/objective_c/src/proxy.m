// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "proxy.h"

#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSValue.h>

@interface ProxyMethod : NSObject
@property(strong) NSMethodSignature *signature;
@property(strong) id block;
- (void)dealloc;
@end

@implementation ProxyMethod
- (void)dealloc {
  self.signature = nil;
  self.block = nil;
  [super dealloc];
}
@end

@implementation DartProxy {
  NSMutableDictionary *methods;
}

+ (instancetype)new {
  return [[self alloc] init];
}

- (instancetype)init {
  if (self) {
    methods = [NSMutableDictionary new];
  }
  return self;
}

- (void)dealloc {
  [methods release];
  [super dealloc];
}

- (void)implementMethod:(SEL) sel
        withSignature:(NSMethodSignature *)signature
        andBlock:(void *)block {
  ProxyMethod *m = [ProxyMethod new];
  m.signature = signature;
  m.block = block;
  [methods setObject:m forKey:[NSValue valueWithPointer:sel]];
  [m release];
}

- (BOOL)respondsToSelector:(SEL)sel {
  return [methods objectForKey:[NSValue valueWithPointer:sel]] != nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  ProxyMethod *m = [methods objectForKey:[NSValue valueWithPointer:sel]];
  return m != nil ? m.signature : nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  [invocation retainArguments];
  SEL sel = invocation.selector;
  ProxyMethod *m = [methods objectForKey:[NSValue valueWithPointer:sel]];
  if (m != nil) {
    [invocation invokeWithTarget:m.block];
  }
}

@end
