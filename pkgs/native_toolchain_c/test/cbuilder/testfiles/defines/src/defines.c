// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <stdio.h>

#define STRINGIFY(X) #X
#define MACRO_IS_UNDEFINED(name) printf("Macro " #name " is undefined.\n");
#define MACRO_IS_DEFINED(name)                                                 \
  printf("Macro " #name " is defined: " STRINGIFY(name) "\n");

int main() {
#ifdef DEBUG
  MACRO_IS_DEFINED(DEBUG);
#else
  MACRO_IS_UNDEFINED(DEBUG);
#endif

#ifdef RELEASE
  MACRO_IS_DEFINED(RELEASE);
#else
  MACRO_IS_UNDEFINED(RELEASE);
#endif

#ifdef NDEBUG
  MACRO_IS_DEFINED(NDEBUG);
#else
  MACRO_IS_UNDEFINED(NDEBUG);
#endif

#ifdef FOO
  MACRO_IS_DEFINED(FOO);
#else
  MACRO_IS_UNDEFINED(FOO);
#endif

#ifdef FIFOO
  MACRO_IS_DEFINED(FIFOO);
#else
  MACRO_IS_UNDEFINED(FIFOO);
#endif

  return 0;
}
