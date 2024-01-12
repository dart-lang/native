// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../model/metadata.dart' as model;

abstract class Metadata {
  Map<String, Object> get metadata;

  const factory Metadata(Map<String, Object> metadata) = model.Metadata;
}
