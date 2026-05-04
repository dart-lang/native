import 'package:test/test.dart';
import 'test_utils.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  test('AOT check', () {
    print('Package root: $packagePathForTests');
    expect(Directory(packagePathForTests).existsSync(), isTrue);
  });
}
