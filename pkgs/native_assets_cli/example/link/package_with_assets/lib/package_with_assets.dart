// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

//TODO: Actually use the assets, needs the AssetBundle interface for Dart. See
//also https://github.com/dart-lang/sdk/issues/54003.
@ResourceIdentifier('used_asset')
String someMethod() => 'Using used_asset';

@ResourceIdentifier('unused_asset')
String someOtherMethod() => 'Using unused_asset';
