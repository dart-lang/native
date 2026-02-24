// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:record_use/record_use_internal.dart';

const callId = Definition(
  'package:js_runtime/js_helper.dart',
  [Name('MyClass'), Name('get:loadDeferredLibrary')],
);
const instanceId = Definition(
  'package:js_runtime/js_helper.dart',
  [Name('MyAnnotation')],
);

const loadingUnitOJs = LoadingUnit('o.js');
const loadingUnit3 = LoadingUnit('3');

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
        loadingUnits: [loadingUnitOJs],
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
        loadingUnits: [loadingUnitOJs],
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
        loadingUnits: [loadingUnit3],
      ),
      const InstanceConstantReference(
        instanceConstant: InstanceConstant(definition: instanceId, fields: {}),
        loadingUnits: [loadingUnit3],
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
        loadingUnits: [loadingUnitOJs],
      ),
    ],
  },
  instances: {},
);

final _testDataUri = findPackageRoot('record_use').resolve('test_data/json/');

final recordedUsesJson = File.fromUri(
  _testDataUri.resolve('recorded_uses_v2.json'),
).readAsStringSync();

final recordedUsesJson2 = File.fromUri(
  _testDataUri.resolve('recorded_uses_v2_2.json'),
).readAsStringSync();
