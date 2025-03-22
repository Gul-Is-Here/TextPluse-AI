import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class ImageToText extends StatefulWidget {
  const ImageToText({super.key});

  @override
  State<ImageToText> createState() => _ImageToTextState();
}

class _ImageToTextState extends State<ImageToText> {
  XFile? pickedImage;
  String myText = "";
  bool scanning = false;

  final ImagePicker _imagePicker = ImagePicker();

  getImage(ImageSource imageSource) async {
    XFile? result = await _imagePicker.pickImage(source: imageSource);
    if (result != null) {
      setState(() {
        pickedImage = result;
      });
      performTextRecognition();
    }
  }

  void performTextRecognition() async {
    setState(() {
      scanning = true;
    });

    try {
      final inputImage = InputImage.fromFilePath(pickedImage!.path);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final textRecognized = await textRecognizer.processImage(inputImage);

      setState(() {
        myText = textRecognized.text;
        scanning = false;
      });
      textRecognizer.close();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Text Recognition App',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 10,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade300, Colors.pink.shade200],
          ),
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20.0),
          children: [
            // Image Display
            Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                height: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child:
                    pickedImage == null
                        ? Center(
                          child: Text(
                            'No Image Selected',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            File(pickedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
              ),
            ),
            SizedBox(height: 20),

            // Buttons for Gallery and Camera
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      getImage(ImageSource.gallery);
                    },
                    icon: Icon(Icons.photo, color: Colors.white),
                    label: Text(
                      'Gallery',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      getImage(ImageSource.camera);
                    },
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    label: Text(
                      'Camera',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Recognized Text Section
            Text(
              'Recognized Text:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            scanning
                ? Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Center(
                    child: SpinKitFadingCircle(color: Colors.white, size: 50),
                  ),
                )
                : Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SingleChildScrollView(
                    child: AnimatedTextKit(
                      isRepeatingAnimation: false,
                      animatedTexts: [
                        TypewriterAnimatedText(
                          myText,
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
