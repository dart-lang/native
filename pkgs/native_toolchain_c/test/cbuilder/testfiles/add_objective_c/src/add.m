// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>

#if DEBUG
#import <stdio.h>
#endif

NSInteger add(NSInteger a, NSInteger b) {
#ifdef DEBUG
  printf("Adding %ld and %ld.\n", (long)a, (long)b);
#endif
  // Use NSNumber from Foundation to test the frameworks flags.
  return [[NSNumber numberWithInteger:(a + b)] longValue];
}
