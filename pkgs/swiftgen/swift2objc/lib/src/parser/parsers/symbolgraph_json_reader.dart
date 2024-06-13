import 'dart:convert';
import 'dart:io';

import '../_core/utils.dart';

class SymbolgraphJsonReader {
  final String symbolgraphJsonPath;

  SymbolgraphJsonReader(this.symbolgraphJsonPath);

  JsonMap read() {
    final jsonStr = File(symbolgraphJsonPath).readAsStringSync();
    return jsonDecode(jsonStr);
  }
}
