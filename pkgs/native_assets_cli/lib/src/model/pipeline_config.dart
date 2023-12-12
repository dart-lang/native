import '../utils/yaml.dart';

abstract class PipelineConfig {
  Uri get configFile;

  Uri get output => outDir.resolve(outputName);

  Uri get outDir;

  Uri get script;

  Map<String, Object> toYaml();

  String toYamlString() => yamlEncode(toYaml());

  String get packageName;

  Uri get packageRoot;

  String get outputName;
}
