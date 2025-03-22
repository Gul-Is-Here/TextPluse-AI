import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

class PDFTextExtractorPage extends StatefulWidget {
  @override
  _PDFTextExtractorPageState createState() => _PDFTextExtractorPageState();
}

class _PDFTextExtractorPageState extends State<PDFTextExtractorPage> {
  String extractedText = "Extracted text will show here";
  bool isLoading = false;

  Future<void> pickAndExtractText() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Step 1: Pick the file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Allow only PDF files
      );

      if (result != null) {
        final filePath = result.files.single.path;

        if (filePath != null) {
          // Step 2: Load the PDF file
          final fileBytes = File(filePath).readAsBytesSync();
          PdfDocument pdfDocument = PdfDocument(inputBytes: fileBytes);

          // Step 3: Extract text from all pages
          String text = PdfTextExtractor(pdfDocument).extractText();

          // Step 4: Update the UI
          setState(() {
            extractedText =
                text.isNotEmpty ? text : "No text found in the PDF.";
          });

          // Dispose the document to release resources
          pdfDocument.dispose();
        }
      }
    } catch (e) {
      setState(() {
        extractedText = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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
          'PDF To Text',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Button to Pick PDF and Extract Text
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
                    onPressed: isLoading ? null : pickAndExtractText,
                    child:
                        isLoading
                            ? SpinKitThreeBounce(color: Colors.white, size: 20)
                            : Text(
                              'Pick PDF and Extract Text',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Extracted Text Section
              Expanded(
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white.withOpacity(0.9),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        extractedText,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
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
}
