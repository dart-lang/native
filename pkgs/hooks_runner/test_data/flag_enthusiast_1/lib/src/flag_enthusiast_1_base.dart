import 'package:fun_with_flags/fun_with_flags.dart';
import 'package:meta/meta.dart' show RecordUse;

class SingleFlag {
  @RecordUse()
  String loadFlag(String country) => FlagLoader.load(country);
}
