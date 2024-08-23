// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSObject.h>

#include "global_test.h"
#include "util.h"

NSString* globalNativeString = @"Hello World";
NSObject* _Nullable globalNativeObject = nil;
int32_t (^_Nullable globalNativeBlock)(int32_t) = nil;
