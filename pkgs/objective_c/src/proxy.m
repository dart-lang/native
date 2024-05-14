// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "proxy.h"

#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSValue.h>

@interface ProxyMethod : NSObject
@property(retain) NSMethodSignature *signature;
@property(retain) id target;
@end

@implementation ProxyMethod
@end

@implementation DartProxy

- (instancetype)init {
  if (self) {
    _methods = [NSMutableDictionary new];
  }
  return self;
}

+ (instancetype)new {
  return [[self alloc] init];
}

- (void)implementMethod:(SEL) sel
        withSignature:(NSMethodSignature *)signature
        andBlock:(void *)block {
  @autoreleasepool {
    ProxyMethod *m = [ProxyMethod new];
    m.signature = signature;
    m.target = block;
    [self.methods setObject:m forKey:[NSValue valueWithPointer:sel]];
  }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  @autoreleasepool {
    ProxyMethod *m = [self.methods objectForKey:[NSValue valueWithPointer:sel]];
    return m ? m.signature : nil;
  }
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  @autoreleasepool {
    [invocation retainArguments];
    SEL sel = invocation.selector;
    ProxyMethod *m = [self.methods objectForKey:[NSValue valueWithPointer:sel]];
    if (m) {
      [invocation invokeWithTarget:m.target];
    }
  }
}

@end
