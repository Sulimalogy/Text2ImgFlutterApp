import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:text2img/credentials.dart';
import 'package:http/http.dart' as http;

class Service {
  static String apiUrl =
      'https://api-inference.huggingface.co/models/ZB-Tech/Text-to-Image';

  static Future<Uint8List> generateImg(String text, Directory genImgDir) async {
    Uint8List? imageData;

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer ${Credentials.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'inputs': text}),
    );
    if (response.statusCode == 200) {
      imageData = response.bodyBytes;
      var random = Random();
      var filename = '${genImgDir.path}/${random.nextInt(1000)}.png';
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      imageData = null;
      throw Exception('Failed to generate image');
    }
    return imageData;
  }
}
