import 'dart:io';

import 'package:jnigen/jnigen.dart';

void main(List<String> args) async {
  final packageRoot = Platform.script.resolve('../');
  final generator = JniGenerator(
    input: Input(
      // Required. List of classes or packages for which bindings should be generated.
      classes: [
        'com.example.in_app_java', // Generate the entire package
        'androidx.emoji2.text.EmojiCompat', // From gradle's compile classpath
        'androidx.emoji2.text.DefaultEmojiCompatConfig', // From gradle's compile classpath
        'android.os.Build', // from gradle's compile classpath
      ],
      // Optional. List of directories that contain the source files for which to generate bindings.
      sourcePath: [packageRoot.resolve('android/app/src/main/java')],
      // Optional. Configuration to search for Android SDK libraries.
      androidSdk: AndroidSdk(
        addGradleDeps: true,
        androidExample: packageRoot,
      ),
    ),
    output: Output(
      dart: DartOutput(
        // Required. Output path for generated bindings.
        path: packageRoot.resolve('lib/android_utils.g.dart'),
        // Optional. Write bindings into a single file (instead of one file per class).
        structure: OutputStructure.singleFile,
      ),
    ),
  );
  await generator.generate();
}
