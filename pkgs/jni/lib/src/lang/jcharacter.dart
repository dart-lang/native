import '../accessors.dart';
import '../jni.dart';
import '../jobject.dart';
import '../jvalues.dart';
import '../third_party/generated_bindings.dart';
import '../types.dart';

class JCharacterType extends JObjType<JCharacter> {
  const JCharacterType();

  @override
  String get signature => r"Ljava/lang/Character;";

  @override
  JCharacter fromRef(JObjectPtr ref) => JCharacter.fromRef(ref);

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

  JCharacter.fromRef(
    JObjectPtr ref,
  ) : super.fromRef(ref);

  /// The type which includes information such as the signature of this class.
  static const type = JCharacterType();

  static final _class = Jni.findJClass(r"java/lang/Character");

  static final _ctorId =
      Jni.accessors.getMethodIDOf(_class.reference, r"<init>", r"(C)V");

  JCharacter(int c)
      : super.fromRef(Jni.accessors.newObjectWithArgs(
            _class.reference, _ctorId, [JValueChar(c)]).object);

  static final _charValueId =
      Jni.accessors.getMethodIDOf(_class.reference, r"charValue", r"()C");

  int charValue({bool deleteOriginal = false}) {
    final ret = Jni.accessors.callMethodWithArgs(
        reference, _charValueId, JniCallType.charType, []).char;
    if (deleteOriginal) {
      delete();
    }
    return ret;
  }
}
