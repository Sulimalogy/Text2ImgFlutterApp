import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
      getImgs();
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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          titleTextStyle: const TextStyle(color: Colors.deepPurpleAccent),
          backgroundColor: Colors.white,
          title: const Text('Text2Img',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          centerTitle: true),
      body: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      style: const TextStyle(
                          color: Color.fromRGBO(124, 77, 255, 1)),
                      decoration: const InputDecoration(
                        labelText: 'Enter text to generate image',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.deepPurpleAccent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _imageData != null
                        ? SizedBox(
                            child: Center(
                              child: Image.memory(
                                _imageData!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : const SizedBox(
                            height: 250,
                            child: Center(
                              child: Text(
                                'Enter text to generate an image',
                                style: TextStyle(
                                    color: Colors.deepPurpleAccent,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 40.0,
                      child: ElevatedButton(
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
                    ),
                    const SizedBox(height: 15),
                    const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("History",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                        ]),
                    const SizedBox(height: 10),
                    imgs.isEmpty ? const Text("No Images") : const SizedBox(),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 pictures per row
                        mainAxisSpacing: 5.0,
                        crossAxisSpacing: 10.0,
                      ),
                      itemCount: imgs.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File(imgs[index]),
                            fit: BoxFit.contain,
                            semanticLabel: index.toString(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            _loading
                ? Container(
                    height: height,
                    width: width,
                    color: const Color.fromARGB(148, 254, 254, 254),
                    child: const Center(
                      child: SpinKitFadingCircle(
                        color: Colors.deepPurpleAccent,
                        size: 100.0,
                      ),
                    ),
                  )
                : const SizedBox(),
          ]),
    );
  }
}
