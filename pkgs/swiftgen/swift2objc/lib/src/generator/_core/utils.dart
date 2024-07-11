import 'package:swift2objc/src/ast/_core/shared/parameter.dart';

String generateParameters(List<Parameter> params) {
  return params.map((param) {
    final String labels;
    if (param.internalName != null) {
      labels = "${param.name} ${param.internalName}";
    } else {
      labels = param.name;
    }
    
    return "${labels}: ${param.type.name}";
  }).join(", ");
}
