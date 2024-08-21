// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "proxy.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSValue.h>

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

@interface ProxyMethod : NSObject
@property(strong) NSMethodSignature *signature;
@property(strong) id block;
@end
@implementation ProxyMethod
@end

@implementation DartProxyBuilder {
  __strong NSMutableDictionary *methods;
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

- (void)implement:(SEL)sel withMethod:(__strong ProxyMethod*)m {
  @synchronized(methods) {
    [methods setObject:m forKey:[NSValue valueWithPointer:sel]];
  }
}

- (void)implementMethod:(SEL)sel
        withSignature:(__strong NSMethodSignature *)signature
        andBlock:(__strong id)block {
  __strong ProxyMethod *m = [ProxyMethod new];
  m.signature = signature;
  m.block = block;
  [self implement:sel withMethod:m];
}

- (NSDictionary*)copyMethods NS_RETURNS_RETAINED {
  return [methods copy];
}
@end

@implementation DartProxy {
  __strong NSDictionary *methods;
}

- (ProxyMethod*)getMethod:(SEL)sel {
  return [methods objectForKey:[NSValue valueWithPointer:sel]];
}

+ (instancetype)newFromBuilder:(__strong DartProxyBuilder*)builder {
  return [[self alloc] initFromBuilder:builder];
}

- (instancetype)initFromBuilder:(__strong DartProxyBuilder*)builder {
  if (self) {
    methods = [builder copyMethods];
  }
  return self;
}

- (BOOL)respondsToSelector:(SEL)sel {
  return [self getMethod:sel] != nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  __strong ProxyMethod *m = [self getMethod:sel];
  return m != nil ? m.signature : nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  [invocation retainArguments];
  __strong ProxyMethod *m = [self getMethod:invocation.selector];
  if (m != nil) {
    [invocation invokeWithTarget:m.block];
  }
}

@end
