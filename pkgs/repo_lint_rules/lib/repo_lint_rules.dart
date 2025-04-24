import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'src/dont_import_outside_src_rule.dart';

PluginBase createPlugin() => _MyLintRulesPlugin();

class _MyLintRulesPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    DontImportOutsideSrcRule(),
  ];
}
