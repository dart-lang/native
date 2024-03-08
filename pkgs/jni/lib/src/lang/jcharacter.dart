import '../accessors.dart';
import '../jni.dart';
import '../jobject.dart';
import '../jreference.dart';
import '../jvalues.dart';
import '../third_party/generated_bindings.dart';
import '../types.dart';

final class JCharacterType extends JObjType<JCharacter> {
  const JCharacterType();

  @override
  String get signature => r"Ljava/lang/Character;";

  @override
  JCharacter fromReference(JObjectPtr ref) => JCharacter.fromReference(ref);

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
    JObjectPtr ref,
  ) : super.fromReference(ref);

  /// The type which includes information such as the signature of this class.
  static const type = JCharacterType();

  static final _class = Jni.findJClass(r"java/lang/Character");

  static final _ctorId =
      Jni.accessors.getMethodIDOf(_class.reference.pointer, r"<init>", r"(C)V");

  JCharacter(int c)
      : super.fromReference(Jni.accessors.newObjectWithArgs(
            _class.reference.pointer, _ctorId, [JValueChar(c)]).object);

  static final _charValueId = Jni.accessors
      .getMethodIDOf(_class.reference.pointer, r"charValue", r"()C");

  int charValue({bool releaseOriginal = false}) {
    reference.ensureNotNull();
    final ret = Jni.accessors.callMethodWithArgs(
        reference.pointer, _charValueId, JniCallType.charType, []).char;
    if (releaseOriginal) {
      release();
    }
    return ret;
  }
}
