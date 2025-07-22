// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

final snippets = [
  {
    'code': '''
int overloadedMethods() {
    Accumulator acc1 = new Accumulator();
    acc1.add(10);
    acc1.add(10, 10);
    acc1.add(10, 10, 10);

    Accumulator acc2 = new Accumulator(20);
    acc2.add(acc1);

    Accumulator acc3 = new Accumulator(acc2);
    return acc3.accumulator;
}''',
    'fileName': 'overloaded_methods.dart',
  },
  {
    'code': '''
int implementInlineInterface() {
    Runnable runnable = new Runnable() {
        @Override
        public int run() {
            return 0;
        }
    };
    return runnable.run();
}''',
    'fileName': 'implement_inline_interface.dart',
  },
  {
    'code': '''
public class RunnableClass implements Runnable {

  public RunnableClass() {}

  @Override
  public int run() {
    return 5;
  }
}
int implementNormalInterface() {
    Runnable runnable = new RunnableClass();
    return runnable.run();
}''',
    'fileName': 'implement_normal_interface.dart',
  },
];
