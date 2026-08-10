import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  runApp(
    MaterialApp(
      home: Scaffold(body: Center(child: Text('Docs dir: ${dir.path}'))),
    ),
  );
}
