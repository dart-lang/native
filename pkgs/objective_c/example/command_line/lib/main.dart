import 'dart:io';

import 'package:objective_c/objective_c.dart';

void main() {
  // Objective-C is only supported on macOS and iOS.
  assert(Platform.isMacOS || Platform.isIOS);

  print('Hello World'.toNSString().toDartString());
}
