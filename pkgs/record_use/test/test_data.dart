// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:record_use/record_use.dart';
import 'package:record_use/src/canonicalization_context.dart';
import 'package:record_use/src/recordings.dart';

const callId = Getter(
  'loadDeferredLibrary',
  Class('MyClass', Library('package:js_runtime/js_helper.dart')),
  isInstanceMember: false,
);
const instanceId = Class(
  'MyAnnotation',
  Library('package:js_runtime/js_helper.dart'),
);
const enumId = Enum(
  'MyEnum',
  Library('package:js_runtime/js_helper.dart'),
);

const loadingUnitOJs = LoadingUnit('o.js');
const loadingUnit3 = LoadingUnit('3');

final recordedUses = Recordings(
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
        loadingUnit: loadingUnitOJs,
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
        loadingUnit: loadingUnitOJs,
      ),
    ],
  },
  instances: {
    instanceId: [
      const InstanceConstantReference(
        instanceConstant: InstanceConstant(
          definition: instanceId,
          fields: {'a': IntConstant(42), 'b': NullConstant()},
        ),
        loadingUnit: loadingUnit3,
      ),
      const InstanceConstantReference(
        instanceConstant: InstanceConstant(definition: instanceId, fields: {}),
        loadingUnit: loadingUnit3,
      ),
    ],
    enumId: [
      const InstanceConstantReference(
        instanceConstant: EnumConstant(
          definition: enumId,
          index: 0,
          name: 'val1',
          fields: {'a': IntConstant(42)},
        ),
        loadingUnit: loadingUnit3,
      ),
    ],
  },
).canonicalizeChildren(CanonicalizationContext());

final recordedUses2 = Recordings(
  calls: {
    callId: [
      const CallWithArguments(
        positionalArguments: [BoolConstant(false), IntConstant(1)],
        namedArguments: {
          'freddy': StringConstant('mercury'),
          'answer': IntConstant(42),
        },
        loadingUnit: loadingUnitOJs,
      ),
    ],
  },
  instances: {},
).canonicalizeChildren(CanonicalizationContext());

final _testDataUri = findPackageRoot('record_use').resolve('test_data/json/');

final recordedUsesJson = File.fromUri(
  _testDataUri.resolve('recorded_uses_v2.json'),
).readAsStringSync();

final recordedUsesJson2 = File.fromUri(
  _testDataUri.resolve('recorded_uses_v2_2.json'),
).readAsStringSync();
