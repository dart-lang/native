// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use

import 'package:meta/meta.dart';

//TODO: Actually use the assets, needs the AssetBundle interface for Dart. See
//also https://github.com/dart-lang/sdk/issues/54003.

/// A method that uses an asset.
@RecordUse()
String someMethod() => 'Using used_asset';

/// Another method that uses an asset.
@RecordUse()
String someOtherMethod() => 'Using unused_asset';
