// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "protocol.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSValue.h>
#import <objc/runtime.h>

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

@interface DOBJCDartProtocolClass : NSObject
- (instancetype)initWithClass: (Class)cls;
@end

@implementation DOBJCDartProtocolClass {
  Class clazz;
}

- (instancetype)initWithClass: (Class)cls {
  if (self) {
    clazz = cls;
  }
  return self;
}

- (void)dealloc {
  objc_disposeClassPair(clazz);
}

@end

@implementation DOBJCDartProtocolBuilder {
  NSMutableDictionary *methods;
  DOBJCDartProtocolClass* clazz;
}

- (instancetype)initWithClass: (void*)cls {
  if (self) {
    methods = [NSMutableDictionary new];
    clazz = [[DOBJCDartProtocolClass alloc] initWithClass: (__bridge Class)cls];
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

- (NSDictionary*)getMethods {
  return methods;
}

- (DOBJCDartProtocolClass*)getClass {
  return clazz;
}

@end

@implementation DOBJCDartProtocol {
  NSDictionary *methods;
  DOBJCDartProtocolClass* clazz;
  Dart_Port dispose_port;
}

- (id)getDOBJCDartProtocolMethodForSelector:(SEL)sel {
  return [methods objectForKey:[NSValue valueWithPointer:sel]];
}

- (instancetype)initDOBJCDartProtocolFromDartProtocolBuilder:
    (DOBJCDartProtocolBuilder*)builder
    withDisposePort:(Dart_Port)port {
  if (self) {
    methods = [builder getMethods];
    clazz = [builder getClass];
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
