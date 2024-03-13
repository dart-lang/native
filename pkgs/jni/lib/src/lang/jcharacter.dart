import '../jobject.dart';
import '../jreference.dart';
import '../jvalues.dart';
import '../types.dart';

final class JCharacterType extends JObjType<JCharacter> {
  const JCharacterType();

  @override
  String get signature => r"Ljava/lang/Character;";

  @override
  JCharacter fromReference(JReference reference) =>
      JCharacter.fromReference(reference);

  @override
  JObjType get superType => const JObjectType();

  @override
  final superCount = 1;

  @override
  int get hashCode => (JCharacterType).hashCode;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == (JCharacterType) && other is JCharacterType;
  }
}

class JCharacter extends JObject {
  @override
  // ignore: overridden_fields
  late final JObjType<JCharacter> $type = type;

  JCharacter.fromReference(
    JReference reference,
  ) : super.fromReference(reference);

  /// The type which includes information such as the signature of this class.
  static const type = JCharacterType();

  static final _class = JClass.forName(r"java/lang/Character");

  static final _ctorId = _class.constructorId(r"(C)V");

  JCharacter(int c)
      : super.fromReference(_ctorId(_class, referenceType, [JValueChar(c)]));

  static final _charValueId = _class.instanceMethodId(r"charValue", r"()C");

  int charValue({bool releaseOriginal = false}) {
    reference.ensureNotNull();
    final ret = _charValueId(this, const jcharType(), []);
    if (releaseOriginal) {
      release();
    }
    return ret;
  }
}
