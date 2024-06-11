extension CastMapToJson on Map {
  Map<String, dynamic> castToJson() => _castMapToJson(this);
}

Map<String, dynamic> _castMapToJson(Map map) {
  final castedMap = <String, dynamic>{};

  for (final key in map.keys) {
    final value = map[key];
    if (value is Map) {
      castedMap[key] = _castMapToJson(value);
    } else if (value is List) {
      castedMap[key] = value
          .map(
            (e) => e is Map ? _castMapToJson(e) : e,
          )
          .toList();
    } else {
      castedMap[key] = map[key];
    }
  }

  return castedMap;
}
