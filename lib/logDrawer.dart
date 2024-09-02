import 'dart:typed_data';
import 'package:flutter/material.dart';

class LogDrawer extends StatefulWidget {
  const LogDrawer({super.key});

  @override
  _LogDrawerState createState() => _LogDrawerState();
}

class _LogDrawerState extends State<LogDrawer> {
    final List _imageHistory = [];
  Uint8List? _imageData;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: [
        for (var i in _imageHistory)
          Image.memory(
            _imageData!,
            fit: BoxFit.contain,
            semanticLabel: i.toString(),
          ),
      ]),
    );
  }
}
