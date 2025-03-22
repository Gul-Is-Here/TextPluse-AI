import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();

  late Uint8List _imageData = Uint8List(0);
  bool _isLoading = false;

  void _convertTextToImage() async {
    setState(() {
      _isLoading = true;
    });

    const apiUrl = 'https://api.stability.ai/v2beta/stable-image/generate/sd3';
    const apiKey =
        'sk-GQGaiXSdwf7XpHAfllj7DEpbBMwheQg1QNVtnBsEh8YH4FHm'; // Replace with your actual API key

    final request =
        http.MultipartRequest('POST', Uri.parse(apiUrl))
          ..headers.addAll({
            'Authorization': 'Bearer $apiKey',
            'Accept': 'image/*',
          })
          ..fields['prompt'] =
              _textController.text.isNotEmpty
                  ? _textController.text
                  : 'Default prompt text'
          ..fields['output_format'] = 'jpeg';

    try {
      final response = await request.send();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        setState(() {
          _imageData = bytes;
        });
      } else {
        final error = await response.stream.bytesToString();
        _showErrorDialog('Failed to generate image: $error');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: const Text(
            'Convert Text to Image',
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Input Field
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      hintText: 'Enter your input',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Image Display
              if (_imageData.isNotEmpty)
                Expanded(
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(_imageData),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20),

              // Generate Image Button
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.deepPurple,
                  ),
                  child: TextButton(
                    onPressed: _isLoading ? null : _convertTextToImage,
                    child:
                        _isLoading
                            ? SizedBox(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              'Generate Image',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Error',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Ok',
                style: TextStyle(fontSize: 18, color: Colors.deepPurple),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
