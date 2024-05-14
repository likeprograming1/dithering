import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io'; // 추가
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AtkinsonDitheringImage extends StatefulWidget {
  @override
  _AtkinsonDitheringImageState createState() => _AtkinsonDitheringImageState();
}

class _AtkinsonDitheringImageState extends State<AtkinsonDitheringImage> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final ByteData data = await rootBundle.load('assets/image.jpg');
    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;
    setState(() {
      _image = image;
    });
  }

  Future<void> _saveImageToGallery() async {
    if (_image == null) return;

    try {
      final ByteData? byteData =
          await _image!.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        print('Failed to convert image to byte data.');
        return;
      }
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 앱 문서 디렉토리에 이미지를 저장
      final directory = await getApplicationDocumentsDirectory(); // 수정된 부분
      if (directory != null) {
        final path = '${directory.path}/image2.png';

        final File imageFile = File(path);
        await imageFile.writeAsBytes(pngBytes);

        // 저장된 이미지 경로 출력
        print('Image saved to: $path');
      } else {
        print('Failed to get external storage directory.');
      }
    } catch (e) {
      print('Failed to save image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atkinson Dithering Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? CircularProgressIndicator()
                : CustomPaint(
                    size: Size(
                        _image!.width.toDouble(), _image!.height.toDouble()),
                    painter: AtkinsonDitheringPainter(image: _image!),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveImageToGallery();
              },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}

class AtkinsonDitheringPainter extends CustomPainter {
  final ui.Image image;

  AtkinsonDitheringPainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..filterQuality = FilterQuality.high;

    // 이미지를 그립니다.
    canvas.drawImageRect(
      image,
      Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTRB(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

void main() {
  runApp(MaterialApp(
    home: AtkinsonDitheringImage(),
  ));
}
