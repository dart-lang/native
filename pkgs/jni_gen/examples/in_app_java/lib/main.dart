import 'package:flutter/material.dart';
import 'package:jni/jni.dart';

// The hierarchy created in generated code will mirror the java package
// structure. This is an implementation convenience and we may allow
// more customization in future.
import 'android_utils/com/example/in_app_java.dart';

JlObject activity = JlObject.fromRef(Jni.getInstance().getCurrentActivity());

void showToast(String text) {
  final jstr = JlString.fromString(text);
  AndroidUtils.showToast(activity, jstr, 0);
  jstr.delete();
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Show toast'),
              onPressed: () => showToast('😀'),
            ),
          ],
        ),
      ),
    );
  }
}
