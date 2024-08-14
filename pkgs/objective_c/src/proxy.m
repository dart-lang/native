// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "proxy.h"

#import <Foundation/NSDictionary.h>
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
}
@end

@implementation DartProxyBuilder {
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

- (void)implement:(SEL)sel withMethod:(ProxyMethod*)m {
  @synchronized(methods) {
    [methods setObject:m forKey:[NSValue valueWithPointer:sel]];
  }
}

- (void)implementMethod:(SEL)sel
        withSignature:(NSMethodSignature *)signature
        andBlock:(void *)block {
  ProxyMethod *m = [ProxyMethod new];
  m.signature = signature;
  m.block = (__bridge id)block;
  [self implement:sel withMethod:m];
}

- (NSDictionary*)copyMethods {
  return [methods copy];
}
@end

@implementation DartProxy {
  NSDictionary *methods;
}

- (ProxyMethod*)getMethod:(SEL)sel {
  return [methods objectForKey:[NSValue valueWithPointer:sel]];
}

+ (instancetype)newFromBuilder:(DartProxyBuilder*)builder {
  return [[self alloc] initFromBuilder:builder];
}

- (instancetype)initFromBuilder:(DartProxyBuilder*)builder {
  if (self) {
    methods = [builder copyMethods];
  }
  return self;
}

- (BOOL)respondsToSelector:(SEL)sel {
  return [self getMethod:sel] != nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  ProxyMethod *m = [self getMethod:sel];
  return m != nil ? m.signature : nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  [invocation retainArguments];
  ProxyMethod *m = [self getMethod:invocation.selector];
  if (m != nil) {
    [invocation invokeWithTarget:m.block];
  }
}

@end
