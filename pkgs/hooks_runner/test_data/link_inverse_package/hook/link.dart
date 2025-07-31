// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';

void main(List<String> arguments) async {
  await link(arguments, (input, output) async {
    //This asset should never make it, as it is flowing in the wrong direction
    //of the dependency tree.
    output.metadata.add('link_inverse_app', 'key', 'value');
  });
}
