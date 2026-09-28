import 'package:flutter/material.dart';

void main() {
  runApp(const SafetyObservationApp());
}

class SafetyObservationApp extends StatelessWidget {
  const SafetyObservationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safety Observation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Safety Observation'),
        ),
      ),
    );
  }
}
