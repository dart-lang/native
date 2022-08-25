// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jni_gen/jni_gen.dart';
import '../test_util/test_util.dart';

const jacksonPreamble = '// Generated from jackson-core which is licensed under'
    ' the Apache License 2.0.\n'
    '// The following copyright from the original authors applies.\n'
    '// See https://github.com/FasterXML/jackson-core/blob/2.14/LICENSE\n'
    '//\n'
    '// Copyright (c) 2007 - The Jackson Project Authors\n'
    '// Licensed under the Apache License, Version 2.0 (the "License")\n'
    '// you may not use this file except in compliance with the License.\n'
    '// You may obtain a copy of the License at\n'
    '//\n'
    '//     http://www.apache.org/licenses/LICENSE-2.0\n'
    '//\n'
    '// Unless required by applicable law or agreed to in writing, software\n'
    '// distributed under the License is distributed on an "AS IS" BASIS,\n'
    '// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n'
    '// See the License for the specific language governing permissions and\n'
    '// limitations under the License.\n';

Future<void> generate(
    {bool isTest = false,
    bool generateFullVersion = false,
    bool useAsm = false}) async {
  final deps = ['com.fasterxml.jackson.core:jackson-core:2.13.3'];
  await generateBindings(
    testName: 'jackson_core_test',
    sourceDepNames: deps,
    jarDepNames: deps,
    useAsmBackend: useAsm,
    preamble: jacksonPreamble,
    isThirdParty: true,
    classes: (generateFullVersion)
        ? ['com.fasterxml.jackson.core']
        : [
            'com.fasterxml.jackson.core.JsonFactory',
            'com.fasterxml.jackson.core.JsonParser',
            'com.fasterxml.jackson.core.JsonToken',
          ],
    isGeneratedFileTest: isTest,
    options: WrapperOptions(
        fieldFilter: CombinedFieldFilter([
          excludeAll<Field>([
            ['com.fasterxml.jackson.core.JsonFactory', 'DEFAULT_QUOTE_CHAR'],
            ['com.fasterxml.jackson.core.Base64Variant', 'PADDING_CHAR_NONE'],
            ['com.fasterxml.jackson.core.base.ParserMinimalBase', 'CHAR_NULL'],
            ['com.fasterxml.jackson.core.io.UTF32Reader', 'NC'],
          ]),
          CustomFieldFilter((decl, field) => !field.name.startsWith("_")),
        ]),
        methodFilter:
            CustomMethodFilter((decl, method) => !method.name.startsWith('_'))),
  );
}

void main() => generate(isTest: false);
