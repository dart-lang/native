import 'package:test/test.dart';

void expectString(String a, String b) {
  final trimmedA = a.replaceAll(RegExp(r'\s+'), '');
  final trimmedB = b.replaceAll(RegExp(r'\s+'), '');
  ;

  expect(trimmedA, trimmedB);
}
