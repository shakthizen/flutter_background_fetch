import 'dart:io';

import 'package:auto_start_flutter/auto_start_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

// Mandatory if the App is obfuscated or using Flutter 3.1+
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    //simpleTask will be emitted here.
    print(
      "Native called background task: $task",
    );

    final p = await Geolocator.checkPermission();
    final loc = await Geolocator.getCurrentPosition();

    await Dio().post(
      "https://6389aded4eccb986e897300f.mockapi.io/data",
      data: {
        "os": Platform.operatingSystem,
        "at": DateTime.now().toIso8601String(),
        "permissions": p.name,
        "location": {
          "lat": loc.latitude,
          "lon": loc.longitude,
        },
      },
    );

    print(p.name);

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.locationWhenInUse.request();
  await Permission.locationAlways.request();

  getAutoStartPermission();

  Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    isInDebugMode: true,
    // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );
  Workmanager().registerPeriodicTask(
    "task-identifier",
    "simpleTask",
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Background Tasks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Background Tasks"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Background tas started',
            ),
          ],
        ),
      ),
    );
  }
}
