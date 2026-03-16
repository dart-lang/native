import 'package:flutter/material.dart';
import 'dart:ffi' as ffi;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const MyHomePage(),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ffi.DynamicLibrary _lib;

  @override
  void initState() {
    super.initState();
    _lib = ffi.DynamicLibrary.open('libc++_shared.so');
  }

  // Example of using a foreign function from libc++_shared.so.
  // Generate a random number between 0 and 99 using the C standard library's rand() function.
  int getRandomInt() {
    final getTime = _lib
        .lookup<ffi.NativeFunction<ffi.Int64 Function()>>('rand')
        .asFunction<int Function()>();
    final time = getTime();
    return time % 100;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Android libc++_shared.so Example')),
    body: Center(child: Text('${getRandomInt()}')),
  );
}
