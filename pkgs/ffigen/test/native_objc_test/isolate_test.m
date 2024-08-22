// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

#include "util.h"

typedef void (^Listener)(int32_t);

@interface Sendable : NSObject {}
@property int32_t value;
+ (Listener)dummyMethodToForceGenerationOfListener;
@end

@implementation Sendable
@end
