#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint jni.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'jni'
  s.version          = '0.0.1'
  s.summary          = 'macOS implementation of JNI.'
  s.description      = <<-DESC
Enables interop with Java using JNI.
                       DESC
  s.homepage         = 'https://github.com/dart-lang/native/tree/main/pkgs/jni'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Hossein Yousefi' => 'yousefi@google.com' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.xcconfig              = {
    'LIBRARY_SEARCH_PATHS' => [
        '"$(JAVA_HOME)/lib/server"'
    ],
    'HEADER_SEARCH_PATHS' => [
        '"$(JAVA_HOME)/include/darwin"',
        '"$(JAVA_HOME)/include"'
    ],
    'RUNPATH_SEARCH_PATH' => [
        '"$(JAVA_HOME)/lib/server"'
    ],
    'OTHER_LDFLAGS' => [
        '-ljvm'
    ]
  }
  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
