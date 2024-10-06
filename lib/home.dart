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
        titleTextStyle: const TextStyle(color: Colors.deepPurpleAccent),
        backgroundColor: Colors.white,
        title: const Text('Text2Img'),
        centerTitle: true,
        leading: Builder(builder: (BuildContext context2) {
          return IconButton(
            color: Colors.deepPurpleAccent,
            icon: const Icon(Icons.history),
            onPressed: () => Scaffold.of(context2).openDrawer(),
          );
        }),
      ),
      body: Stack(
        children: [
          // _backgroundEffect(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _loading ? _loadingScreen() : const SizedBox(),
                TextField(
                  controller: _controller,
                  style:
                      const TextStyle(color: Color.fromRGBO(124, 77, 255, 1)),
                  decoration: const InputDecoration(
                    labelText: 'Enter text to generate image',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurpleAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _imageData != null
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
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ),
                      ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _loading
                      ? null
                      : () {
                          if (_controller.text.isNotEmpty) {
                            _generateImage(_controller.text);
                          }
                        },
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("Generate"), Icon(Icons.image)]),
                ),
                const SizedBox(height: 10),
                const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("History",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                    ]),
                const SizedBox(height: 20),
                imgs.isEmpty ? const Text("No Images") : const SizedBox(),
                /*Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 pictures per row
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio:
                          0.6, // This allows variable height but fixed width
                    ),
                    itemCount: imgs.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          File(imgs[index]),
                          fit: BoxFit.contain,
                          semanticLabel: index.toString(),
                        ), // Cover ensures variable height handling
                      );
                    },
                  ),
                ),
                ),
                */
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingScreen() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      color: Colors.transparent,
      child: const Center(
        child: SpinKitFadingCircle(
          color: Colors.deepPurpleAccent,
          size: 100.0,
        ),
      ),
    );
  }
}
