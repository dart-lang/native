import 'dart:io';

import 'package:jnigen/jnigen.dart';

void main(List<String> args) {
  final packageRoot = Platform.script.resolve('../');
  generateJniBindings(
    Config(
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: packageRoot.resolve('lib/android_utils.g.dart'),
          structure: OutputStructure.singleFile,
        ),
      ),
      androidSdkConfig: AndroidSdkConfig(addGradleDeps: true),
      sourcePath: [packageRoot.resolve('android/app/src/main/java')],
      classes: [
        'com.example.in_app_java', // Generate the entire package
        'androidx.emoji2.text.EmojiCompat', // From gradle's compile classpath
        'androidx.emoji2.text.DefaultEmojiCompatConfig', // From gradle's compile classpath
        'android.os.Build', // from gradle's compile classpath
        'java.util.HashMap', // from gradle's compile classpath
      ],
    ),
  );
}
