import 'package:yaml/yaml.dart';

Map<String, Object?> convertYamlMapToJsonMap(YamlMap yamlMap) {
  final jsonMap = <String, Object?>{};
  yamlMap.forEach((key, value) {
    if (key is! String) {
      // Handle non-string keys if your YAML allows them, or throw an error.
      // For typical JSON conversion, keys are expected to be strings.
      throw ArgumentError('YAML map keys must be strings for JSON conversion.');
    }
    jsonMap[key] = _convertYamlValue(value);
  });
  return jsonMap;
}

Object? _convertYamlValue(dynamic yamlValue) {
  if (yamlValue is YamlMap) {
    return convertYamlMapToJsonMap(yamlValue);
  } else if (yamlValue is YamlList) {
    return yamlValue.map(_convertYamlValue).toList();
  } else {
    // For primitive types (String, int, double, bool, null)
    return yamlValue;
  }
}
