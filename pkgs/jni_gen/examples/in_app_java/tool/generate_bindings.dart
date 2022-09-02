import 'package:jni_gen/jni_gen.dart';

void main(List<String> args) async {
  final config = Config(
    sourcePath: [Uri.directory('android/app/src/main/java')],
    classes: ['com.example.in_app_java.AndroidUtils'],
    cRoot: Uri.directory('src/android_utils'),
    dartRoot: Uri.directory('lib/android_utils'),
    libraryName: 'android_utils',
    androidSdkConfig: AndroidSdkConfig(
      versions: [31],
    ),
  );
  await generateJniBindings(config);
}
