// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef OBJECTIVE_C_SRC_NS_NUMBER_H_
#define OBJECTIVE_C_SRC_NS_NUMBER_H_

#import <Foundation/Foundation.h>

@interface NSNumber (NSNumberTypeCheck)
@property(readonly) bool isFloat;
@property(readonly) bool isBool;
@end

#endif // OBJECTIVE_C_SRC_NS_NUMBER_H_
