// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <iostream>

int main() {
#ifdef DEBUG
  std::cout << "Running in debug mode." << std::endl;
#endif
  std::cout << "Hello world." << std::endl;
  return 0;
}

