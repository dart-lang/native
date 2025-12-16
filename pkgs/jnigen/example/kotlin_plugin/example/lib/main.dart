import 'package:flutter/material.dart';
import 'package:jni/_internal.dart';
import 'package:jni/jni.dart';
import 'package:kotlin_plugin/kotlin_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kotlin Plugin Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Kotlin Plugin Example Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<String>? answer;

  late Example example;

  @override
  void initState() {
    super.initState();
    example = Example();
  }

  @override
  void dispose() {
    example.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'What is the answer to life, the universe, and everything?',
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  answer = () async {
                    final _thinker = $Thinker(message: () async {
                      await Future.delayed(Duration(milliseconds: 300));
                      return JString.fromString("App");
                    });
                    final thinker = Thinker.implement(_thinker);
                    final value1 = (await example.thinkBeforeAnswering(thinker))
                        .toDartString(releaseOriginal: true);
                    final value2 = (await thinker.message()).toDartString();
                    return value1 + '\n' + value2;
                  }();
                });
              },
              child: const Text('Think...'),
            ),
            FutureBuilder<String>(
              future: answer,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return const SizedBox();
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    return Text(
                      'Thinking...',
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                  case ConnectionState.done:
                    return Text(
                      snapshot.data ?? "I don't know!",
                      style: Theme.of(context).textTheme.headlineMedium,
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
