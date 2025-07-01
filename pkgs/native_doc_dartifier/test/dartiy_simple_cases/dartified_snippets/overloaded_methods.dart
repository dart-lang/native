import '../bindings.dart';

int overloadedMethods() {
  final acc1 = Accumelator();
  acc1.add(10);
  acc1.add$1(10, 10);
  acc1.add$2(10, 10, 10);

  final acc2 = Accumelator.new$1(20);
  acc2.add$3(acc1);

  final acc3 = Accumelator.new$2(acc2);
  return acc3.accumulator;
}