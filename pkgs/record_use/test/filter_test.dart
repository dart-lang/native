// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/record_use_internal.dart';
import 'package:test/test.dart';

void main() {
  test('filter recordings by package and nested constants', () {
    const myPackage = 'my_package';
    const otherPackage = 'other_package';

    const myDefinition = Definition(
      'package:$myPackage/my_lib.dart',
      [Name('myFunc')],
    );
    const otherDefinition = Definition(
      'package:$otherPackage/other_lib.dart',
      [Name('OtherClass')],
    );

    const otherInstance = InstanceConstant(
      definition: otherDefinition,
      fields: {},
    );

    final recordings = Recordings(
      calls: {
        myDefinition: [
          const CallWithArguments(
            positionalArguments: [otherInstance],
            namedArguments: {},
            loadingUnits: [],
          ),
        ],
      },
      instances: {},
    );

    final filtered = recordings.filter(definitionPackageName: myPackage);

    expect(filtered.calls, hasLength(1));
    final call = filtered.calls[myDefinition]!.first as CallWithArguments;
    expect(call.positionalArguments.first, isA<UnsupportedConstant>());
    expect(
      (call.positionalArguments.first as UnsupportedConstant).message,
      contains('other_package'),
    );
  });

  test('filter recordings by package and nested constants in collections', () {
    const myPackage = 'my_package';
    const otherPackage = 'other_package';

    const myDefinition = Definition(
      'package:$myPackage/my_lib.dart',
      [Name('myFunc')],
    );
    const otherDefinition = Definition(
      'package:$otherPackage/other_lib.dart',
      [Name('OtherClass')],
    );

    const otherInstance = InstanceConstant(
      definition: otherDefinition,
      fields: {},
    );

    final recordings = Recordings(
      calls: {
        myDefinition: [
          const CallWithArguments(
            positionalArguments: [
              ListConstant([otherInstance]),
              MapConstant([MapEntry(StringConstant('key'), otherInstance)]),
            ],
            namedArguments: {},
            loadingUnits: [],
          ),
        ],
      },
      instances: {},
    );

    final filtered = recordings.filter(definitionPackageName: myPackage);

    expect(filtered.calls, hasLength(1));
    final call = filtered.calls[myDefinition]!.first as CallWithArguments;

    final list = call.positionalArguments[0] as ListConstant;
    expect(list.value.first, isA<UnsupportedConstant>());

    final map = call.positionalArguments[1] as MapConstant;
    expect(map.entries.first.value, isA<UnsupportedConstant>());
  });

  test('filter recordings by package and nested enums', () {
    const myPackage = 'my_package';
    const otherPackage = 'other_package';

    const myDefinition = Definition(
      'package:$myPackage/my_lib.dart',
      [Name('myFunc')],
    );
    const otherEnumDefinition = Definition(
      'package:$otherPackage/other_lib.dart',
      [Name('OtherEnum')],
    );

    const otherEnum = EnumConstant(
      definition: otherEnumDefinition,
      index: 0,
      name: 'val1',
    );

    final recordings = Recordings(
      calls: {
        myDefinition: [
          const CallWithArguments(
            positionalArguments: [otherEnum],
            namedArguments: {},
            loadingUnits: [],
          ),
        ],
      },
      instances: {},
    );

    final filtered = recordings.filter(definitionPackageName: myPackage);

    expect(filtered.calls, hasLength(1));
    final call = filtered.calls[myDefinition]!.first as CallWithArguments;
    expect(call.positionalArguments.first, isA<UnsupportedConstant>());
    expect(
      (call.positionalArguments.first as UnsupportedConstant).message,
      contains('OtherEnum'),
    );
  });
}
