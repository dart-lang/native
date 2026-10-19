-keep class com.github.dart_lang.jni.** { *; }

# Kotlin classes that package:jni looks up by name to support suspend functions.
# Continuation must also keep its name in generated JNI method descriptors.
-keep interface kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
-keep class kotlin.coroutines.intrinsics.IntrinsicsKt { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep class kotlin.Unit { *; }
