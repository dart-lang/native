import 'dart:io';

import 'package:jnigen/jnigen.dart';

void main(List<String> args) async {
  final packageRoot = Platform.script.resolve('../');
  final generator = JniGenerator(
    input: Input(
      sourcePath: [packageRoot.resolve('android/app/src/main/java')],
      classes: [
        'com.example.in_app_java', // Generate the entire package
        'androidx.emoji2.text.EmojiCompat', // From gradle's compile classpath
        'androidx.emoji2.text.DefaultEmojiCompatConfig', // From gradle's compile classpath
        'android.os.Build', // from gradle's compile classpath
      ],
      androidSdk: AndroidSdk(
        addGradleDeps: true,
        androidExample: packageRoot,
      ),
    ),
    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve('lib/android_utils.g.dart'),
        structure: OutputStructure.singleFile,
      ),
    ),
  );
  await generator.generate();
}
