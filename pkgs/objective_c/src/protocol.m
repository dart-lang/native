// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "protocol.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSValue.h>

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

@implementation DOBJCDartProtocolBuilder {
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

- (void)implement:(SEL)sel withBlock:(id)block {
  @synchronized(methods) {
    [methods setObject:block forKey:[NSValue valueWithPointer:sel]];
  }
}

- (void)implementMethod:(SEL)sel withBlock:(void*)block {
  [self implement:sel withBlock:(__bridge id)block];
}

- (NSDictionary*)copyMethods NS_RETURNS_RETAINED {
  return [methods copy];
}
@end

@implementation DOBJCDartProtocol {
  NSDictionary *methods;
  Dart_Port dispose_port;
}

- (id)getDOBJCDartProtocolMethodForSelector:(SEL)sel {
  return [methods objectForKey:[NSValue valueWithPointer:sel]];
}

- (instancetype)initDOBJCDartProtocolFromDartProtocolBuilder:
    (DOBJCDartProtocolBuilder*)builder
    withDisposePort:(Dart_Port)port {
  if (self) {
    methods = [builder copyMethods];
    dispose_port = port;
  }
  return self;
}

- (void)dealloc {
  if (dispose_port != ILLEGAL_PORT) {
    Dart_PostInteger_DL(dispose_port, 0);
  }
}

@end
