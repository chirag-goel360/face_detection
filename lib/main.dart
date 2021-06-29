import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(
    MyHomePage(),
  );
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _file;
  String result = '';
  List<Face> faces;
  dynamic image;
  ImagePicker imagePicker;
  FaceDetector faceDetector;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableClassification: true,
        minFaceSize: 0.1,
        mode: FaceDetectorMode.accurate,
      ),
    );
  }

  doFaceDetection() async {
    final inputImage = InputImage.fromFile(
      _file,
    );
    faces = await faceDetector.processImage(
      inputImage,
    );
    drawRectangleAroundFaces();
    if (faces.length > 0) {
      if (faces[0].smilingProbability > 0.5) {
        result = "Smiling 😃";
      } else {
        result = "Serious 😑";
      }
    }
  }

  drawRectangleAroundFaces() async {
    image = await _file.readAsBytes();
    image = await decodeImageFromList(image);
    setState(() {});
  }

  _imgFromCamera() async {
    PickedFile image = await imagePicker.getImage(
      source: ImageSource.camera,
    );
    _file = File(
      image.path,
    );
    setState(() {
      if (_file != null) {
        doFaceDetection();
      }
    });
  }

  _imgFromGallery() async {
    PickedFile image = await imagePicker.getImage(
      source: ImageSource.gallery,
    );
    _file = File(
      image.path,
    );
    setState(() {
      if (_file != null) {
        doFaceDetection();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    faceDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'images/wall.jpg',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 70,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: TextButton(
                        onPressed: _imgFromGallery,
                        onLongPress: _imgFromCamera,
                        child: Container(
                          width: 350,
                          height: 300,
                          child: image != null
                              ? Center(
                                  child: FittedBox(
                                    fit: BoxFit.fill,
                                    child: Container(
                                      width: image.width.toDouble(),
                                      height: image.height.toDouble(),
                                      child: CustomPaint(
                                        painter: FacePainter(
                                          rect: faces,
                                          imageFile: image,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: Colors.black,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 20,
                ),
                child: Text(
                  '$result',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  List<Face> rect;
  var imageFile;
  FacePainter({
    @required this.rect,
    @required this.imageFile,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(
        imageFile,
        Offset.zero,
        Paint(),
      );
    }
    Paint paint = Paint();
    paint.color = Colors.red;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 16;
    if (rect != null) {
      for (Face rectangle in rect) {
        canvas.drawRect(
          rectangle.boundingBox,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
