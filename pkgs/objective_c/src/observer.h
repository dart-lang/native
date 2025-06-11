// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef OBJECTIVE_C_SRC_OBSERVER_H_
#define OBJECTIVE_C_SRC_OBSERVER_H_

#import <Foundation/NSObject.h>
#import <Foundation/NSKeyValueObserving.h>

/**
 * Protocol for observing changes to values of objects.
 */
@protocol Observer<NSObject>
@required
- (void)observeValueForKeyPath:(NSString *)keyPath
    ofObject:(id)object
    change:(NSDictionary<NSKeyValueChangeKey, id> *)change
    context:(void *)context;
@end

/**
 * Represents a single KVO observation. Each observation creates a new
 * DOBJCObservation, even for the same observer, observed object, and keyPath.
 */
@interface DOBJCObservation : NSObject
- (instancetype)initForKeyPath:(NSString*)keyPath
    ofObject:(id)object
    withObserver:(id<Observer>)observer
    options:(NSKeyValueObservingOptions) options
    context:(void *)context;
- (void)remove;
- (void)dealloc;
- (void*)debugObserver;
@end

#endif  // OBJECTIVE_C_SRC_OBSERVER_H_
