import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:text2img/credentials.dart';
import 'package:text2img/logDrawer.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  Uint8List? _imageData;
  bool _loading = false;
  // final AudioPlayer _audioPlayer = AudioPlayer();
  var random = Random();
  late Directory tmpDir;
  late Directory genImgDir;
  List imgs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      tmpDir = await getTemporaryDirectory();
      print("tmpDir: ${tmpDir.path}");
      genImgDir = Directory("${tmpDir.path}/text2img/generatedImgs/");
      print("All tmpDir: ${genImgDir.path}");

      await genImgDir.create(recursive: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getImgs() {
    imgs = genImgDir
        .listSync()
        .map((item) => item.path)
        .where((item) => item.endsWith(".png"))
        .toList(growable: false);
    print(imgs);
  }

  Future<void> _generateImage(String text) async {
    setState(() {
      _loading = true;
    });

    const String apiUrl =
        'https://api-inference.huggingface.co/models/ZB-Tech/Text-to-Image';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer ${Credentials.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'inputs': text}),
    );

    if (response.statusCode == 200) {
      getImgs();
      setState(() {
        _imageData = response.bodyBytes; // Extract the binary image data
        _loading = false;
      });
      var filename = '${genImgDir.path}/${random.nextInt(100)}.png';
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      setState(() {
        _loading = false;
        _imageData = null;
      });
      throw Exception('Failed to generate image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: LogDrawer(
        imageHistory: imgs,
      ),
      appBar: AppBar(
        title: const Text('Text2Img'),
        centerTitle: true,
        leading: Builder(builder: (BuildContext context2) {
          return IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Scaffold.of(context2).openDrawer(),
          );
        }),
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
                    labelText: 'Enter text to generate image',
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
