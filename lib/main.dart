import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text to Image Generator',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  Uint8List? _imageData;
  final List _imageHistory = [];
  bool _loading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  Future<void> _generateImage(String text) async {
    setState(() {
      _loading = true;
    });

    // Play a sound effect when the user presses the button
    // await _audioPlayer.play('sounds/click.mp3');

    const String apiUrl =
        'https://api-inference.huggingface.co/models/ZB-Tech/Text-to-Image';
    const String apiKey =
        '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'; // Replace with your API key
    print("requesting: $apiUrl \n $text");
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'inputs': text}),
    );
    print("response.statusCode : ${response.statusCode}");

    if (response.statusCode == 200) {
      setState(() {
        _imageData = response.bodyBytes; // Extract the binary image data
        _loading = false;

        // _audioPlayer
        //    .play('sounds/success.mp3'); // Play success sound
        // _imageHistory
        String name = getRandString(20);
        File('$name.png').writeAsBytes(response.bodyBytes);
      });
    } else {
      setState(() {
        _loading = false;
        _imageData = null;
      });
      // _audioPlayer.play('sounds/error.mp3'); // Play error sound
      throw Exception('Failed to generate image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*drawer: Drawer(
        child: Column(children: [
          for (var i in _imageHistory)
            Image.memory(
              _imageData!,
              fit: BoxFit.contain,
              semanticLabel: i.toString(),
            ),
        ]),
      ),*/
      appBar: AppBar(
        title: const Text('Text2Img'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _backgroundEffect(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Enter text',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurpleAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _generateImage(_controller.text);
                    }
                  },
                  child: const Text(
                    'Generate Image',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                _loading
                    ? const Expanded(
                        child: Center(
                          child: SpinKitFadingCircle(
                            color: Colors.deepPurpleAccent,
                            size: 100.0,
                          ),
                        ),
                      )
                    : _imageData != null
                        ? Expanded(
                            child: Center(
                              child: Image.memory(
                                _imageData!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : const Expanded(
                            child: Center(
                              child: Text(
                                'Enter text to generate an image',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 16),
                              ),
                            ),
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundEffect() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade800, Colors.deepPurpleAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
