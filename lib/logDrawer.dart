import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class LogDrawer extends StatefulWidget {
  LogDrawer({super.key, required this.imageHistory});
  List imageHistory = [];

  @override
  _LogDrawerState createState() => _LogDrawerState();
}

class _LogDrawerState extends State<LogDrawer> {
  Uint8List? _imageData;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: [
        for (var i in widget.imageHistory)
          Image.file(
            File(i),
            fit: BoxFit.contain,
            semanticLabel: i.toString(),
          ),
      ]),
    );
  }
}
