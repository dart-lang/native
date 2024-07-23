import 'cbuilder.dart';

/// A programming language that can be selected for compilation of source files.
///
/// See [CBuilder.language] for more information.
class Language {
  /// The name of the language.
  final String name;

  const Language._(this.name);

  static const Language c = Language._('c');

  static const Language cpp = Language._('c++');

  static const Language objectiveC = Language._('objective c');

  /// Known values for [Language].
  static const List<Language> values = [
    c,
    cpp,
    objectiveC,
  ];

  @override
  String toString() => name;
}
