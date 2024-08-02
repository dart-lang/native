// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';

import 'package:record_use/record_use_internal.dart';

final Usages emptyUsages = Usages(
  metadata: Metadata(version: Version(1, 2, 3).toString()),
  calls: [],
  instances: [],
);

final Usages recordedUses = Usages(
  metadata: Metadata(
    version: Version(1, 6, 2, pre: 'wip', build: '5.-.2.z').toString(),
    comment:
        'Recorded references at compile time and their argument values, as far'
        ' as known, to definitions annotated with @RecordReference',
  ),
  instances: [
    Usage(
      definition: Definition(
        identifier: Identifier(
          uri: Uri.parse('file://lib/_internal/js_runtime/lib/js_helper.dart')
              .toString(),
          name: 'MyAnnotation',
        ),
        line: 15,
        column: 30,
      ),
      references: [
        Reference(
          location: Location(
            uri: Uri.parse('file://lib/_internal/js_runtime/lib/js_helper.dart')
                .toString(),
            line: 40,
            column: 30,
          ),
          fields: Fields(fields: [
            Field(
              className: 'className',
              name: 'a',
              value: FieldValue(intValue: 42),
            ),
          ]),
          loadingUnit: '3',
        ),
      ],
    ),
  ],
  calls: [
    Usage(
      definition: Definition(
        identifier: Identifier(
          uri: Uri.parse('file://lib/_internal/js_runtime/lib/js_helper.dart')
              .toString(),
          parent: 'MyClass',
          name: 'get:loadDeferredLibrary',
        ),
        line: 12,
        column: 67,
        loadingUnit: 'part_15.js',
      ),
      references: [
        Reference(
          arguments: Arguments(
            constArguments: ConstArguments(
              positional: {
                0: FieldValue(stringValue: 'lib_SHA1'),
                1: FieldValue(boolValue: false),
                2: FieldValue(intValue: 1),
              },
              named: {
                'leroy': FieldValue(stringValue: 'jenkins'),
                'freddy': FieldValue(stringValue: 'mercury'),
              },
            ),
          ),
          location: Location(
            uri: Uri.parse(
                    'file://benchmarks/OmnibusDeferred/dart/OmnibusDeferred.dart')
                .toString(),
            line: 14,
            column: 49,
          ),
          loadingUnit: 'o.js',
        ),
        Reference(
          arguments: Arguments(
            constArguments: ConstArguments(
              positional: {
                0: FieldValue(stringValue: 'lib_SHA1'),
                2: FieldValue(intValue: 0),
                4: FieldValue(
                  mapValue: StringMapValue(
                    value: {
                      'key': FieldValue(intValue: 99),
                    },
                  ),
                )
              },
              named: {
                'leroy': FieldValue(stringValue: 'jenkins'),
                'albert': FieldValue(
                  listValue: ListValue(
                    value: [
                      FieldValue(stringValue: 'camus'),
                      FieldValue(stringValue: 'einstein'),
                    ],
                  ),
                ),
              },
            ),
            nonConstArguments: NonConstArguments(
              positional: [1],
              named: ['freddy'],
            ),
          ),
          location: Location(
            uri: Uri.parse(
                    'file://benchmarks/OmnibusDeferred/dart/OmnibusDeferred.dart')
                .toString(),
            line: 14,
            column: 48,
          ),
          loadingUnit: 'o.js',
        ),
      ],
    ),
  ],
);
