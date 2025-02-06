import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../logging/logging.dart';
import '../util/find_package.dart';

class GradleTools {
  static final currentDir = Directory('.');

  // Maven Central root location
  static String repoLocation = 'https://repo1.maven.org/maven2';

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

  static Future<Uri?> getGradleWExecutable() async {
    final pkg = await findPackageRoot('jnigen');
    if (Platform.isLinux || Platform.isMacOS) {
      return pkg!.resolve('gradlew');
    } else if (Platform.isWindows) {
      return pkg!.resolve('gradlew.bat');
    }
    return null;
  }

  static Future<void> _runGradleCommand(
      List<MavenDependency> deps, String targetDir,
      {bool extractSources = false}) async {
    final gradleWrapper = await getGradleWExecutable();
    final gradle = _getStubGradle(
      deps,
      File(targetDir).absolute.path,
    );
    final tempDir = await currentDir.createTemp('maven_temp_');
    await createStubProject(tempDir);
    final tempGradle = join(tempDir.path, 'temp_build.gradle.kts');
    log.finer('using Gradle stub:\n$gradle');
    await File(tempGradle).writeAsString(gradle);
    final gradleArgs = [
      '-b', // specify gradle file to run
      tempGradle,
      extractSources ? 'extractSourceJars' : 'copyJars'
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
    for (var i = 0; i < deps.length; i++) {
      final sourceJarLocation = deps[i].toURLString(repoLocation);
      await File(join(targetDir, deps[i].filename()))
          .writeAsBytes(await http.readBytes(Uri.parse(sourceJarLocation)));
    }
    // Use gradle to extract the source jars.
    // This flow is needed because Gradle
    // defaults to compiled jars where available.
    final tempDir = await currentDir.createTemp('maven_temp_');
    await _runGradleCommand(deps, extractSources: true, targetDir);
    await tempDir.delete(recursive: true);
  }

  static Future<void> createStubProject(Directory rootTempDir) async {
    final sourceDir = await Directory(join(rootTempDir.path, 'src/main/java/'))
        .create(recursive: true);
    log.info(sourceDir);

    // A settings.gradle file and a valid Java source file is required
    // to generate a build
    await File(join(rootTempDir.path, 'settings.gradle')).writeAsString('');

    final javaSourceStub = join(rootTempDir.path, 'Main.java');
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
    await _runGradleCommand(deps, targetDir);
    await tempDir.delete(recursive: true);
  }

  static String _getStubGradle(List<MavenDependency> deps, String targetDir,
      {String javaVersion = '11', String sourcesDir = '.'}) {
    final depDecls = <String>[];
    // Use implementation configuration
    for (var dep in deps) {
      depDecls.add(dep.toGradleDependency('implementation'));
    }
    return '''
    plugins {
        java
    }
    
    repositories {
        mavenCentral()
        google()
    }
    
    java {
        sourceCompatibility = JavaVersion.VERSION_$javaVersion
        targetCompatibility = JavaVersion.VERSION_$javaVersion
    }
    
    tasks.register<Copy>("copyJars") {
    from(configurations.runtimeClasspath)
    into("$targetDir")
    }
    
    tasks.register<Copy>("extractSourceJars") {
      duplicatesStrategy = DuplicatesStrategy.INCLUDE
      val sourcesDir = fileTree("$targetDir")
      sourcesDir.forEach {
        if (it.name.endsWith(".jar")) {
        from(zipTree(it))
        into("$targetDir")
        }
      }      
    }
    
    dependencies {
        ${depDecls.join("\n")}
    }''';
  }
}

/// Maven dependency with group ID, artifact ID, and version.
class MavenDependency {
  MavenDependency(this.groupID, this.artifactID, this.version,
      {this.otherTags = const {}});

  factory MavenDependency.fromString(String fullName) {
    final components = fullName.split(':');
    if (components.length != 3) {
      throw ArgumentError('invalid name for maven dependency: $fullName');
    }
    return MavenDependency(components[0], components[1], components[2]);
  }

  String groupID, artifactID, version;
  Map<String, String> otherTags;

  String toGradleDependency(String configuration) {
    return '$configuration("$groupID:$artifactID:$version")';
  }

  String filename({bool isSource = true}) {
    final extension = isSource ? '-sources.jar' : '.jar';
    return '$artifactID-$version$extension';
  }

  String toURLString(String repoLocation) {
    var parts = <String>[repoLocation];
    parts.addAll(groupID.split('.'));
    parts.addAll(artifactID.split('.'));
    parts.add(version);
    parts.add(filename());
    return parts.join('/');
  }
}
