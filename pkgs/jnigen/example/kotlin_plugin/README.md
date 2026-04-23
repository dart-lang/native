# kotlin_plugin

This example generates bindings for a Kotlin-based library. It showcases the conversion of `suspend fun` in Kotlin to `async` functions in Dart.

The command to regenerate JNI bindings is:
```
dart run jnigen --config jnigen.yaml # run from kotlin_plugin project root 
```

The `example/` app must have its dependencies resolved (eg `flutter pub get`) before running JNIgen.

Note that `jnigen.yaml` of this example contains the option `suspend_fun_to_async: true`. This will generate `async` method bindings from Kotlin's `suspend fun`s.

## Creating a new Kotlin plugin

Running `flutter create --template=plugin_ffi --platform=android kotlin_plugin` creates the skeleton of an Android plugin.

In order to use Kotlin, `build.gradle` must be modified in the following way:

```gradle
apply plugin: 'com.android.library'
// Add the line below:
apply plugin: 'kotlin-android'
```

```gradle
android {
    // Add the following block
    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }
    // ...
}
```

Now the Kotlin code in `src/main/kotlin` is included in the plugin.
