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
