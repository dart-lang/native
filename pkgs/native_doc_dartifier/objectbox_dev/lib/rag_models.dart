// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:objectbox/objectbox.dart';

@Entity()
class ClassSummaryRAGModel {
  @Id()
  int id = 0;

  String summary;

  @HnswIndex(dimensions: 3072, distanceType: VectorDistanceType.cosine)
  @Property(type: PropertyType.floatVector)
  List<double> embeddings;

  ClassSummaryRAGModel(this.summary, this.embeddings);
}
