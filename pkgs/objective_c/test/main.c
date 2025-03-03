// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Verify that the required symbols were not stripped from the binary.

#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

#define ASSERT_SYMBOL(s)                                                       \
  if (dlsym(RTLD_DEFAULT, s) == 0) {                                           \
    fprintf(stderr, "Missing symbol: %s\n", s);                                \
    exit(1);                                                                   \
  }

int main() {
  ASSERT_SYMBOL("DOBJC_disposeObjCBlockWithClosure"); // objective_c.c
  ASSERT_SYMBOL("DOBJC_runOnMainThread");

  ASSERT_SYMBOL("DOBJC_disposeObjCBlockWithClosure"); // objective_c.c
  ASSERT_SYMBOL("DOBJC_runOnMainThread");             // objective_c.m
  ASSERT_SYMBOL("OBJC_CLASS_$_DOBJCDartProtocol");    // protocol.m
  // objective_c_bindings_generated.m
  ASSERT_SYMBOL("_ObjectiveCBindings_wrapListenerBlock_ovsamd");
  return 0;
}
