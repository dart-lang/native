import 'dart:convert';
import 'dart:io';

const _cSourceTemplate = '''
#include <sys/stat.h>

#include "constants.g.h"


''';

const _cHeaderTemplate = '''
#include <stdint.h>

#define my_UNDEFINED 9223372036854775807;
''';

const _dartTemplate = '''
// ignore_for_file: non_constant_identifier_names

import 'libc_bindings.dart';
''';

void addConstantToCSource(String constant, StringBuffer b) {
  b.write('''
int64_t my_get_$constant(void) {
#ifdef $constant
  return $constant;
#endif
  return my_UNDEFINED;
}
''');
}

void addConstantToCHeader(String constant, StringBuffer b) {
  b.write('''
int64_t my_get_$constant(void);
''');
}

void addConstantToDart(String constant, StringBuffer b) {
  b.writeln('''
int get $constant {
  final v = get_$constant();
  if (v == my_UNDEFINED) {
    throw UnsupportedError('$constant');
  } else {
    return v;
  }
}
''');
}

void main() {
  final constants =
      (json.decode(File('constants.json').readAsStringSync()) as List)
          .cast<String>();

  final cSourceBuffer = StringBuffer(_cSourceTemplate);
  final cHeaderBuffer = StringBuffer(_cHeaderTemplate);
  final dartBuffer = StringBuffer(_dartTemplate);

  for (final constant in constants) {
    addConstantToCHeader(constant, cHeaderBuffer);
    addConstantToCSource(constant, cSourceBuffer);
    addConstantToDart(constant, dartBuffer);
  }
  File('lib/src/constants.g.dart').writeAsStringSync(dartBuffer.toString());
  File('src/constants.g.c').writeAsStringSync(cSourceBuffer.toString());
  File('src/constants.g.h').writeAsStringSync(cHeaderBuffer.toString());
}
