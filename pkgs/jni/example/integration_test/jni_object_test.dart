import 'dart:io';
import 'dart:ffi';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:ffi/ffi.dart';

import 'package:jni/jni.dart';
import 'package:jni/jni_object.dart';

void main() {
  if (!Platform.isAndroid) {
    Jni.spawn();
  }

  final jni = Jni.getInstance();
  testWidgets('get JNI Version', (tester) async {
    final env = jni.getEnv();
    expect(env.GetVersion(), isNot(equals(0)));
  });

  testWidgets('Manually lookup & call Long.toHexString static method',
      (tester) async {
    final arena = Arena();
    final env = jni.getEnv();
    final longClass = env.FindClass("java/lang/Long".toNativeChars(arena));
    final hexMethod = env.GetStaticMethodID(
        longClass,
        "toHexString".toNativeChars(arena),
        "(J)Ljava/lang/String;".toNativeChars(arena));

    for (var i in [1, 80, 13, 76, 1134453224145]) {
      final jres = env.CallStaticObjectMethodA(
          longClass, hexMethod, Jni.jvalues([JValueLong(i)], allocator: arena));

      final res = env.asDartString(jres);
      expect(res, equals(i.toRadixString(16)));
      env.DeleteLocalRef(jres);
    }
    env.DeleteLocalRef(longClass);
    arena.releaseAll();
  });

  testWidgets("asJString extension method", (tester) async {
    final env = jni.getEnv();
    const str = "QWERTY QWERTY";
    final jstr = env.asJString(str);
    expect(str, equals(env.asDartString(jstr)));
    env.DeleteLocalRef(jstr);
  });

  testWidgets("Convert back and forth between dart and java string",
      (tester) async {
    final arena = Arena();
    final env = jni.getEnv();
    const str = "ABCD EFGH";
    final jstr = env.NewStringUTF(str.toNativeChars(arena));
    final jchars = env.GetStringUTFChars(jstr, nullptr);
    final dstr = jchars.toDartString();
    env.ReleaseStringUTFChars(jstr, jchars);
    expect(str, equals(dstr));

    env.deleteAllLocalRefs([jstr]);
    arena.releaseAll();
  });

  testWidgets("Print something from Java", (tester) async {
    final arena = Arena();
    final env = jni.getEnv();
    final system = env.FindClass("java/lang/System".toNativeChars(arena));
    final field = env.GetStaticFieldID(system, "out".toNativeChars(arena),
        "Ljava/io/PrintStream;".toNativeChars(arena));
    final out = env.GetStaticObjectField(system, field);
    final printStream = env.GetObjectClass(out);
    /*
    final println = env.GetMethodID(printStream, "println".toNativeChars(arena),
        "(Ljava/lang/String;)V".toNativeChars(arena));
	*/
    const str = "\nHello JNI!";
    final jstr = env.asJString(str);
    env.deleteAllLocalRefs([system, printStream, jstr]);
    arena.releaseAll();
  });

  testWidgets("Long.intValue() using JniObject", (tester) async {
    final longClass = jni.findJniClass("java/lang/Long");

    final longCtor = longClass.getConstructorID("(J)V");

    final long = longClass.newObject(longCtor, [176]);

    final intValue = long.callIntMethodByName("intValue", "()I", []);
    expect(intValue, equals(176));

    long.delete();
    longClass.delete();
  });

  testWidgets("call a static method using JniClass APIs", (tester) async {
    final integerClass = jni.wrapClass(jni.findClass("java/lang/Integer"));
    final result = integerClass.callStaticObjectMethodByName(
        "toHexString", "(I)Ljava/lang/String;", [31]);

    final resultString = result.asDartString();

    result.delete();
    expect(resultString, equals("1f"));

    integerClass.delete();
  });

  testWidgets("Example for using getMethodID", (tester) async {
    final longClass = jni.findJniClass("java/lang/Long");
    final bitCountMethod = longClass.getStaticMethodID("bitCount", "(J)I");

    final random = jni.newInstance("java/util/Random", "()V", []);

    final nextIntMethod = random.getMethodID("nextInt", "(I)I");

    for (int i = 0; i < 100; i++) {
      int r = random.callIntMethod(nextIntMethod, [256 * 256]);
      int bits = 0;
      final jbc =
          longClass.callStaticIntMethod(bitCountMethod, [JValueLong(r)]);
      while (r != 0) {
        bits += r % 2;
        r = (r / 2).floor();
      }
      expect(jbc, equals(bits));
    }

    random.delete();
    longClass.delete();
  });

  testWidgets("invoke_", (tester) async {
    final m = jni.invokeLongMethod(
        "java/lang/Long", "min", "(JJ)J", [JValueLong(1234), JValueLong(1324)]);
    expect(m, equals(1234));
  });

  testWidgets("retrieve_", (tester) async {
    final maxLong = jni.retrieveShortField("java/lang/Short", "MAX_VALUE", "S");
    expect(maxLong, equals(32767));
  });

  testWidgets("callStaticStringMethod", (tester) async {
    final longClass = jni.findJniClass("java/lang/Long");
    const n = 1223334444;
    final strFromJava = longClass.callStaticStringMethodByName(
        "toOctalString", "(J)Ljava/lang/String;", [JValueLong(n)]);
    expect(strFromJava, equals(n.toRadixString(8)));
    longClass.delete();
  });

  testWidgets("Passing strings in arguments", (tester) async {
    final out = jni.retrieveObjectField(
        "java/lang/System", "out", "Ljava/io/PrintStream;");
    // uncomment next line to see output
    // (\n because test runner prints first char at end of the line)
    //out.callVoidMethodByName(
    //    "println", "(Ljava/lang/Object;)V", ["\nWorks (Apparently)"]);
    out.delete();
  });

  testWidgets("Passing strings in arguments 2", (tester) async {
    final twelve = jni.invokeByteMethod(
        "java/lang/Byte", "parseByte", "(Ljava/lang/String;)B", ["12"]);
    expect(twelve, equals(12));
  });

  testWidgets("use() method", (tester) async {
    final randomInt = jni.newInstance("java/util/Random", "()V", []).use(
        (random) => random.callIntMethodByName("nextInt", "(I)I", [15]));
    expect(randomInt, lessThan(15));
  });

  testWidgets("enums", (tester) async {
    final ordinal = jni
        .retrieveObjectField(
            "java/net/Proxy\$Type", "HTTP", "Ljava/net/Proxy\$Type;")
        .use((f) => f.callIntMethodByName("ordinal", "()I", []));
    expect(ordinal, equals(1));
  });

  testWidgets("Isolate", (tester) async {
    Isolate.spawn(doSomeWorkInIsolate, null);
  });

  testWidgets("JniGlobalRef", (tester) async {
    final uri = jni.invokeObjectMethod(
        "java/net/URI",
        "create",
        "(Ljava/lang/String;)Ljava/net/URI;",
        ["https://www.google.com/search"]);
    final rg = uri.getGlobalRef();
    await Future.delayed(const Duration(seconds: 1), () {
      final env = jni.getEnv();
      // Now comment this line & try to directly use uri local ref
      // in outer scope.
      //
      // You will likely get a segfault, because Future computation is running
      // in different thread.
      //
      // Therefore, don't share JniObjects across functions that can be
      // scheduled across threads, including async callbacks.
      final uri = JniObject.fromGlobalRef(env, rg);
      final scheme =
          uri.callStringMethodByName("getScheme", "()Ljava/lang/String;", []);
      expect(scheme, "https");
      uri.delete();
      rg.deleteIn(env);
    });
    uri.delete();
  });
}

void doSomeWorkInIsolate(Void? _) {
  final jni = Jni.getInstance();
  final random = jni.newInstance("java/util/Random", "()V", []);
  // var r = random.callIntMethodByName("nextInt", "(I)I", [256]);
  // expect(r, lessThan(256));
  // Expect throws an OutsideTestException
  // but you can uncomment below print and see it works
  // print("\n$r");
  random.delete();
}
