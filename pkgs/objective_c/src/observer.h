// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef OBJECTIVE_C_SRC_OBSERVER_H_
#define OBJECTIVE_C_SRC_OBSERVER_H_

#import <Foundation/NSObject.h>
#import <Foundation/NSKeyValueObserving.h>

typedef void (^DOBJCObserverBlock)(NSObject* object, id oldValue, id newValue);

/**
 * Represents a single KVO observation. Each observation uses a new
 * DOBJCObserver, even for the same observed object and keyPath.
 */
@interface DOBJCObserver : NSObject
- (instancetype)initForKeyPath:(NSString*)keyPath
    ofObject:(id)object
    withBlock:(DOBJCObserverBlock)block;
- (void)observeValueForKeyPath:(NSString*)keyPath
    ofObject:(id)object
    change:(NSDictionary<NSKeyValueChangeKey,id>*)change
    context:(void*)context;
- (void)remove;
- (void)dealloc;
@end

#endif  // OBJECTIVE_C_SRC_OBSERVER_H_
