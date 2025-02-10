import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tflite_model.dart';
import 'input_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider<TFLiteModel>(
      create: (context) => TFLiteModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crop Prediction',
      theme: ThemeData(primarySwatch: Colors.green),
      home: InputScreen(),
    );
  }
}
