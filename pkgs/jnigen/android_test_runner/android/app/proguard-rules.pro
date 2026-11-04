# Keep test fixture classes for which jnigen generates bindings.
# Do NOT add `kotlin.**` or `com.github.dart_lang.jni.**` here, so that
# `pkgs/jni/android/consumer-rules.pro` is tested under R8 minification.
-keep class com.github.dart_lang.jnigen.** { *; }
-keep class com.fasterxml.jackson.core.** { *; }

# Keep `Exceptions` attribute for test interfaces (e.g. `StringConverter`) that
# declare checked exceptions and are implemented via `java.lang.reflect.Proxy`.
-keepattributes Exceptions
