import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tts/flutter_tts.dart'; // ✅ New import
import '../models/prediction_model.dart';
import '../database/database_helper.dart';

class UploadScreen extends StatefulWidget {
  final String cropName;
  final bool isNepali;
  final File? image;

  const UploadScreen({
    super.key,
    required this.cropName,
    this.isNepali = true,
    this.image,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final FlutterTts flutterTts = FlutterTts(); // ✅ TTS instance

  String? _predictionResult;
  String? _confidence;
  String? _description;
  String? _solution;
  String? _imageUrl;
  String? _buyLink;

  Map<String, String> get text => widget.isNepali
      ? {
          'title': '${widget.cropName} को लागि छवि अपलोड गर्नुहोस्',
          'camera': 'फोटो खिच्नुहोस्',
          'gallery': 'ग्यालरीबाट अपलोड गर्नुहोस्',
          'back': 'फिर्ता जानुहोस्',
          'result': 'नतिजा: ',
          'speak': 'पढ्नुहोस्',
        }
      : {
          'title': 'Upload Image for ${widget.cropName}',
          'camera': 'Take Photo',
          'gallery': 'Upload from Gallery',
          'back': 'Go Back',
          'result': 'Result: ',
          'speak': 'Speak',
        };

  @override
  void initState() {
    super.initState();
    if (widget.image != null) {
      _image = widget.image;
      _uploadImage(_image!);
    }
  }

  Future<void> _speak() async {
    String toSpeak = '';

    if (_description != null) {
      toSpeak += widget.isNepali ? 'विवरण: $_description\n' : 'Description: $_description\n';
    }
    if (_solution != null) {
      toSpeak += widget.isNepali ? 'समाधान: $_solution\n' : 'Solution: $_solution\n';
    }

    await flutterTts.setLanguage(widget.isNepali ? 'ne-NP' : 'en-US');
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(toSpeak);
  }

  Future<void> _uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.7.101:5000/predict'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var decoded = json.decode(responseBody);
        setState(() {
          _predictionResult = decoded['class'];
          _confidence = decoded['confidence'].toString();
          _description = widget.isNepali ? decoded['description_np'] : decoded['description_en'];
          _solution = widget.isNepali ? decoded['solution_np'] : decoded['solution_en'];
          _imageUrl = decoded['image_url'];
          _buyLink = decoded['buy_link'];
        });

        String timestamp = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
        await DatabaseHelper.instance.insertPrediction(
          PredictionModel(
            result: decoded['class'],
            imagePath: imageFile.path,
            timestamp: timestamp,
          ),
        );

        await _speak(); // ✅ Speak automatically after prediction
      } else {
        setState(() {
          _predictionResult = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _predictionResult = 'Error: $e';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _predictionResult = null;
      });
      await _uploadImage(_image!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f2027),
        title: Text(text['title']!, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF2c5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_image!, height: 200),
                )
              else
                const Icon(Icons.image, size: 100, color: Colors.white54),
              const SizedBox(height: 16),

              if (_predictionResult != null) ...[
                Text('${text['result']}${_predictionResult!}',
                    style: const TextStyle(color: Colors.white, fontSize: 18)),
                if (_confidence != null)
                  Text('Confidence: $_confidence',
                      style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                if (_description != null)
                  Text('Description:\n$_description',
                      style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                if (_solution != null)
                  Text('Solution:\n$_solution',
                      style: const TextStyle(color: Colors.lightGreenAccent)),
                const SizedBox(height: 8),
                if (_imageUrl != null && _imageUrl!.startsWith('http'))
                  Image.network(_imageUrl!, height: 120),
                const SizedBox(height: 8),
                if (_buyLink != null && _buyLink!.startsWith('http'))
                  ElevatedButton.icon(
                    onPressed: () => _launchURL(_buyLink!),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Buy Medicine'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _speak, // ✅ Manual TTS trigger
                  icon: const Icon(Icons.volume_up),
                  label: Text(text['speak']!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                ),
              ],

              const SizedBox(height: 32),
              _actionButton(Icons.camera_alt, text['camera']!, () => _pickImage(ImageSource.camera)),
              const SizedBox(height: 20),
              _actionButton(Icons.photo_library, text['gallery']!, () => _pickImage(ImageSource.gallery)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
