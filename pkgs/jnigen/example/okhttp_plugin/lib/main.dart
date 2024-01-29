import 'dart:async';
import 'dart:convert';

import 'src/okhttp3.dart';
import 'package:flutter/material.dart';
import 'package:jni/jni.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: FutureBuilder(
            future: Http().method(),
            builder: (context, shot) {
              if (!shot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListTile(
                title: Text("Latitude ${shot.data!.latitude}"),
                subtitle: Text("Longitude ${shot.data!.longitude}"),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Http {
  Future<Location> method() async {

    final completer = Completer<Location>();
    try{
      OkHttpClient client = OkHttpClient.new1();
      Request request = Request_Builder()
          .url(HttpUrl.parse(JString.fromString(
          "https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41")))
          .build();
      Response response = client.newCall(request).execute();
      response.use((data) {
        final json = jsonDecode("${data.body().string()}");
        completer.complete(Location.fromJson(json));
      });
    }catch(e){
      print("Erro $e");
    }
    return completer.future;
  }
}

class Location {
  Location({
    this.latitude,
    this.longitude,
  });

  final String? latitude;
  final String? longitude;

  factory Location.fromJson(Map<String, dynamic> json){
    return Location(
      latitude: json['latitude'].toString(),
      longitude: json['longitude'].toString(),
    );
  }
}
