import 'package:fun_with_flags/fun_with_flags.dart';
import 'package:meta/meta.dart' show RecordUse;

class MultiFlag {
  @RecordUse()
  List<String> loadFlag(Iterable<String> countries) =>
      countries.map(FlagLoader.load).toList();
}
