final snippets = [
  {
    'code': '''
int overloadedMethods() {
    Accumelator acc1 = new Accumelator();
    acc1.add(10);
    acc1.add(10, 10);
    acc1.add(10, 10, 10);

    Accumelator acc2 = new Accumelator(20);
    acc2.add(acc1);

    Accumelator acc3 = new Accumelator(acc2);
    return acc3.accumulator;
}''',
    'fileName': 'overloaded_methods.dart',
  },
];
