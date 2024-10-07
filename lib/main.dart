import 'package:flutter/material.dart';
import 'package:text2img/home.dart';

void main() async {
  await Future.delayed(const Duration(seconds: 5));
  runApp(const Text2ImgApp());
}

class Text2ImgApp extends StatelessWidget {
  const Text2ImgApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text to Image Generator',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}
