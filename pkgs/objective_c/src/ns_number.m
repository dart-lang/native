// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import "ns_number.h"

@implementation NSNumber (NSNumberTypeCheck)
- (bool)isFloat {
  return CFNumberIsFloatType((__bridge CFNumberRef)self);
}

- (bool)isBool {
  return CFGetTypeID((__bridge CFTypeRef)self) == CFBooleanGetTypeID();
}

@end
