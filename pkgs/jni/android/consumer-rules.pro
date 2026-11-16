-keep class com.github.dart_lang.jni.** { *; }

# Kotlin classes that package:jni (see `lib/src/kotlin.dart`) and
# jnigen-generated bindings look up by name to support suspend functions.
# Keep this list in sync with `pkgs/jni/lib/src/kotlin.dart`.
-keep class kotlin.Unit { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$Failure { *; }
-keep class kotlin.coroutines.Continuation { *; }
-keep class kotlin.coroutines.intrinsics.CoroutineSingletons { *; }
-keep class kotlin.coroutines.intrinsics.IntrinsicsKt { *; }
