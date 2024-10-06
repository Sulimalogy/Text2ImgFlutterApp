import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:text2img/log_drawer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:text2img/api_service.dart';

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
  late Directory tmpDir;
  late Directory genImgDir;
  List imgs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      tmpDir = await getTemporaryDirectory();
      genImgDir = Directory("${tmpDir.path}/text2img/generatedImgs/");
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
  }

  Future<void> _generateImage(String text) async {
    setState(() {
      _loading = true;
    });

    getImgs();
    Uint8List x = await Service.generateImg(text, genImgDir);
    setState(() {
      _imageData = x; // Extract the binary image data
      _loading = false;
    });
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
                  decoration: InputDecoration(
                    labelText: 'Enter text to generate image',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurpleAccent),
                    ),
                    suffix: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _loading ? null :() {
                        if (_controller.text.isNotEmpty) {
                          _generateImage(_controller.text);
                        }
                      },
                      child: const Icon(Icons.image),
                    ),
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
