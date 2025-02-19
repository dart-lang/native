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

@interface DOBJCProxyMethod : NSObject
@property(strong) NSMethodSignature *signature;
@property(strong) id block;
@end
@implementation DOBJCProxyMethod
@end

@implementation DOBJCDartProxyBuilder {
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

- (void)implement:(SEL)sel withMethod:(DOBJCProxyMethod*)m {
  @synchronized(methods) {
    [methods setObject:m forKey:[NSValue valueWithPointer:sel]];
  }
}

- (void)implementMethod:(SEL)sel
        withSignature:(NSMethodSignature *)signature
        andBlock:(void*)block {
  DOBJCProxyMethod *m = [DOBJCProxyMethod new];
  m.signature = signature;
  m.block = (__bridge id)block;
  [self implement:sel withMethod:m];
}

- (NSDictionary*)copyMethods NS_RETURNS_RETAINED {
  return [methods copy];
}
@end

@implementation DOBJCDartProxy {
  NSDictionary *methods;
  Dart_Port dispose_port;
}

- (DOBJCProxyMethod*)getMethod:(SEL)sel {
  return [methods objectForKey:[NSValue valueWithPointer:sel]];
}

+ (instancetype)newFromBuilder:(DOBJCDartProxyBuilder*)builder
    withDisposePort:(Dart_Port)port {
  return [[self alloc] initFromBuilder:builder withDisposePort:port];
}

- (instancetype)initFromBuilder:(DOBJCDartProxyBuilder*)builder
    withDisposePort:(Dart_Port)port {
  if (self) {
    methods = [builder copyMethods];
    dispose_port = port;
  }
  return self;
}

- (BOOL)respondsToSelector:(SEL)sel {
  return [self getMethod:sel] != nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  DOBJCProxyMethod *m = [self getMethod:sel];
  return m != nil ? m.signature : nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  [invocation retainArguments];
  DOBJCProxyMethod *m = [self getMethod:invocation.selector];
  if (m != nil) {
    [invocation invokeWithTarget:m.block];
  }
}

- (void)dealloc {
  if (dispose_port != ILLEGAL_PORT) {
    Dart_PostInteger_DL(dispose_port, 0);
  }
}

@end
