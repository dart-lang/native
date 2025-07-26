// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

final snippets = [
  {
    'code': '''
Boolean overloadedMethods() {
    Accumulator acc1 = new Accumulator();
    acc1.add(10);
    acc1.add(10, 10);
    acc1.add(10, 10, 10);

    Accumulator acc2 = new Accumulator(20);
    acc2.add(acc1);

    Accumulator acc3 = new Accumulator(acc2);
    return acc3.accumulator == 80;
}''',
    'fileName': 'overloaded_methods.dart',
  },
  {
    'code': '''
Boolean innerClassCall() {
    DoublingAccumulator acc1 = new DoublingAccumulator();
    acc1.add(10);
    acc1.add(10, 10);
    acc1.add(10, 10, 10);

    return acc1.accumulator == 120;
}''',
    'fileName': 'inner_class.dart',
  },
  {
    'code': '''
Boolean backAndForthStrings(){
    String name = "World";
    Example example = new Example();
    String greeting = example.greet(name);
    System.out.println(greeting);
    return greeting == "Hello World";
}''',
    'fileName': 'strings.dart',
  },
  {
    'code': '''
Boolean identifiersSpecialCases(){
    return Example.has\$dollar\$sign() + Example._startsWithUnderscore() == 3;
}''',
    'fileName': 'identifiers.dart',
  },
];
