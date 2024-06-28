// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:asset';

Future<void> main(List<String> args) async {
  print('Hello ${await getWorld()}');
}

Future<String> getWorld() async {
  const asset = ByteAsset('package:simple_data_asset/assetId');
  final byteBuffer = await asset.load();
  return String.fromCharCodes(byteBuffer.asUint8List());
}
