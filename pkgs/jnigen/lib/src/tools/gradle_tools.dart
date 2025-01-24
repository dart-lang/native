import 'dart:io';

import 'package:path/path.dart';

import '../../tools.dart';
import '../logging/logging.dart';
import '../util/find_package.dart';

class GradleTools extends MavenTools {
  static final currentDir = Directory('.');

  /// Helper method since we can't pass inheritStdio option to [Process.run].
  static Future<int> _runCmd(String exec, List<String> args,
      [String? workingDirectory]) async {
    log.info('execute $exec ${args.join(" ")}');
    final proc = await Process.start(exec, args,
        workingDirectory: workingDirectory,
        runInShell: true,
        mode: ProcessStartMode.inheritStdio);
    return proc.exitCode;
  }

  static Future<Uri?> getGradleWExecutable() async{
    final pkg = await findPackageRoot('jnigen');
    if (Platform.isLinux || Platform.isMacOS) {
      return pkg!.resolve('gradlew');
    } else if (Platform.isWindows) {
      return pkg!.resolve('gradlew.bat');
    }
    return null;
  }

  static Future<void> _runGradleCommand(
      List<MavenDependency> deps,
      String targetDir,
      {bool downloadSources = false}
      ) async {
    final gradleWrapper = await getGradleWExecutable();
    final gradle = _getStubGradle(deps, File(targetDir).absolute.path,
        downloadSources: downloadSources);
    final tempDir = await currentDir.createTemp('maven_temp_');
    await createStubProject(tempDir);
    final tempGradle = join(tempDir.path, 'temp_build.gradle.kts');
    log.finer('using Gradle stub:\n$gradle');
    await File(tempGradle).writeAsString(gradle);
    final gradleArgs = [
      '-b',         // specify gradle file to run
      tempGradle,
      'copyTask'
    ];
    await _runCmd(gradleWrapper!.toFilePath(), gradleArgs);
    await Directory(tempDir.path).delete(recursive: true);
  }

  /// Create a list of [MavenDependency] objects from maven coordinates in
  /// string form.
  static List<MavenDependency> deps(List<String> depNames) =>
      depNames.map(MavenDependency.fromString).toList();

  /// Downloads and unpacks source files of [deps] into [targetDir].
  static Future<void> downloadMavenSources(
      List<MavenDependency> deps, String targetDir) async {
    final tempDir = await currentDir.createTemp('maven_temp_');
    await _runGradleCommand(deps, targetDir, downloadSources: true);
    log.info("targetDir: $targetDir");
    await tempDir.delete(recursive: true);
  }

  static Future<void> createStubProject(Directory rootTempDir) async {
    final sourceDir = await Directory(
        join(rootTempDir.path, 'src/main/java/')).create(recursive: true);
    log.info(sourceDir);

    // A settings.gradle file and a valid Java source file is required
    // to generate a build
    await File(
        join(rootTempDir.path, 'settings.gradle')).writeAsString('');
    
    final javaSourceStub = join(rootTempDir.path, "Main.java");
    const javaStubCode = '''
      public class Main {
        public static void main(String[] args) {
            System.out.println("Hello World.");
        }
      }
    ''';
    await File(javaSourceStub).writeAsString(javaStubCode);
  }

  /// Downloads JAR files of all [deps] transitively into [targetDir].
  static Future<void> downloadMavenJars(
      List<MavenDependency> deps, String targetDir) async {
    final tempDir = await currentDir.createTemp('maven_temp_');
    await _runGradleCommand(deps, targetDir, downloadSources: false);
    await tempDir.delete(recursive: true);
  }

  static String _getStubGradle(List<MavenDependency> deps,
      String targetDir,
      {String javaVersion = '11', bool downloadSources = false}) {
    final depDecls = <String>[];
    // Use implementation configuration
    for (var dep in deps) {
      depDecls.add(dep.toGradleDependency('implementation'));
    }
    return '''
    plugins {
        java
        idea
    }
    
    repositories {
        mavenCentral()
        google()
    }
    
    java {
        sourceCompatibility = JavaVersion.VERSION_${javaVersion}
        targetCompatibility = JavaVersion.VERSION_${javaVersion}
    }
    
    idea {
      module {
          setDownloadJavadoc(false)
          setDownloadSources(${downloadSources})
      }
    }
    
    tasks.register<Copy>("copyTask") {
    from(configurations.runtimeClasspath)
    into(\"${targetDir}\")
    //into(\"\$buildDir\/output\/lib\")
    }
    
    dependencies {
        ${depDecls.join("\n")}
    }''';
  }
}