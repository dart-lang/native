import 'package:hooks/hooks.dart' show LinkInput, LinkOutputBuilder;

const prefix = 'used_flags_';

void flagsUsed(
  LinkInput input,
  LinkOutputBuilder output,
  List<String> countries,
) => output.metadata.add(
  'fun_with_flags',
  '$prefix${input.packageName}',
  countries,
);
