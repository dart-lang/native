// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';
import 'package:record_use/record_use_internal.dart';

final callId = Identifier(
  importUri: Uri.parse(
    'file://lib/_internal/js_runtime/lib/js_helper.dart',
  ).toString(),
  scope: 'MyClass',
  name: 'get:loadDeferredLibrary',
);
final instanceId = Identifier(
  importUri: Uri.parse(
    'file://lib/_internal/js_runtime/lib/js_helper.dart',
  ).toString(),
  name: 'MyAnnotation',
);

final recordedUses = Recordings(
  metadata: Metadata(
    version: Version(1, 6, 2, pre: 'wip', build: '5.-.2.z'),
    comment:
        'Recorded references at compile time and their argument values, as'
        ' far as known, to definitions annotated with @RecordUse',
  ),
  calls: {
    callId: [
      const CallWithArguments(
        positionalArguments: [
          StringConstant('lib_SHA1'),
          BoolConstant(false),
          IntConstant(1),
        ],
        namedArguments: {
          'freddy': StringConstant('mercury'),
          'leroy': StringConstant('jenkins'),
        },
        loadingUnit: 'o.js',
      ),
      const CallWithArguments(
        positionalArguments: [
          StringConstant('lib_SHA1'),
          MapConstant([
            MapEntry(StringConstant('key'), IntConstant(99)),
          ]),
          ListConstant([
            StringConstant('camus'),
            ListConstant([
              StringConstant('einstein'),
              StringConstant('insert'),
              BoolConstant(false),
            ]),
            StringConstant('einstein'),
          ]),
        ],
        namedArguments: {
          'freddy': IntConstant(0),
          'leroy': StringConstant('jenkins'),
        },
        loadingUnit: 'o.js',
      ),
    ],
  },
  instances: {
    instanceId: [
      const InstanceConstantReference(
        instanceConstant: InstanceConstant(
          fields: {'a': IntConstant(42), 'b': NullConstant()},
        ),
        loadingUnit: '3',
      ),
      const InstanceConstantReference(
        instanceConstant: InstanceConstant(fields: {}),
        loadingUnit: '3',
      ),
    ],
  },
);

final recordedUses2 = Recordings(
  metadata: Metadata(
    version: Version(1, 6, 2, pre: 'wip', build: '5.-.2.z'),
    comment:
        'Recorded references at compile time and their argument values, as'
        ' far as known, to definitions annotated with @RecordUse',
  ),
  calls: {
    callId: [
      const CallWithArguments(
        positionalArguments: [BoolConstant(false), IntConstant(1)],
        namedArguments: {
          'freddy': StringConstant('mercury'),
          'answer': IntConstant(42),
        },
        loadingUnit: 'o.js',
      ),
    ],
  },
  instances: {},
);

const recordedUsesJson = '''{
  "metadata": {
    "version": "1.6.2-wip+5.-.2.z",
    "comment": "Recorded references at compile time and their argument values, as far as known, to definitions annotated with @RecordUse"
  },
  "constants": [
    {
      "type": "string",
      "value": "lib_SHA1"
    },
    {
      "type": "bool",
      "value": false
    },
    {
      "type": "int",
      "value": 1
    },
    {
      "type": "string",
      "value": "mercury"
    },
    {
      "type": "string",
      "value": "jenkins"
    },
    {
      "type": "string",
      "value": "key"
    },
    {
      "type": "int",
      "value": 99
    },
    {
      "type": "map",
      "value": [
        {
          "key": 5,
          "value": 6
        }
      ]
    },
    {
      "type": "string",
      "value": "camus"
    },
    {
      "type": "string",
      "value": "einstein"
    },
    {
      "type": "string",
      "value": "insert"
    },
    {
      "type": "list",
      "value": [
        9,
        10,
        1
      ]
    },
    {
      "type": "list",
      "value": [
        8,
        11,
        9
      ]
    },
    {
      "type": "int",
      "value": 0
    },
    {
      "type": "int",
      "value": 42
    },
    {
      "type": "null"
    },
    {
      "type": "instance",
      "value": {
        "a": 14,
        "b": 15
      }
    },
    {
      "type": "instance"
    }
  ],
  "recordings": [
    {
      "identifier": {
        "uri": "file://lib/_internal/js_runtime/lib/js_helper.dart",
        "scope": "MyClass",
        "name": "get:loadDeferredLibrary"
      },
      "calls": [
        {
          "type": "with_arguments",
          "positional": [
            0,
            1,
            2
          ],
          "named": {
            "freddy": 3,
            "leroy": 4
          },
          "loading_unit": "o.js"
        },
        {
          "type": "with_arguments",
          "positional": [
            0,
            7,
            12
          ],
          "named": {
            "freddy": 13,
            "leroy": 4
          },
          "loading_unit": "o.js"
        }
      ]
    },
    {
      "identifier": {
        "uri": "file://lib/_internal/js_runtime/lib/js_helper.dart",
        "name": "MyAnnotation"
      },
      "instances": [
        {
          "type": "constant",
          "constant_index": 16,
          "loading_unit": "3"
        },
        {
          "type": "constant",
          "constant_index": 17,
          "loading_unit": "3"
        }
      ]
    }
  ]
}''';

const recordedUsesJson2 = '''{
  "metadata": {
    "version": "1.6.2-wip+5.-.2.z",
    "comment": "Recorded references at compile time and their argument values, as far as known, to definitions annotated with @RecordUse"
  },
  "constants": [
    {
      "type": "bool",
      "value": false
    },
    {
      "type": "int",
      "value": 1
    },
    {
      "type": "string",
      "value": "mercury"
    },
    {
      "type": "int",
      "value": 42
    }
  ],
  "recordings": [
    {
      "identifier": {
        "uri": "file://lib/_internal/js_runtime/lib/js_helper.dart",
        "scope": "MyClass",
        "name": "get:loadDeferredLibrary"
      },
      "calls": [
        {
          "type": "with_arguments",
          "positional": [
            0,
            1
          ],
          "named": {
            "freddy": 2,
            "answer": 3
          },
          "loading_unit": "o.js"
        }
      ]
    }
  ]
}''';
