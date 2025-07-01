import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'login_signup_screen.dart';
import 'upload_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isNepali;
  const HomeScreen({Key? key, this.isNepali = true}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isNepali = true;
  String _weather = '';
  bool _isLoadingWeather = true;
  String selectedCity = 'Current Location';
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, String>> cropTips = [
  {
    "crop": "Apple",
    "tip":
        "Plant apples in well-drained soil with good sunlight. Prune trees during winter to remove dead branches and enhance fruit production.",
    "tip_np":
        "स्याउ राम्रो घाम लाग्ने र पानी निकास राम्रो भएको माटोमा रोप्नुपर्छ। हिउँदमा सुख्खा हाँगा काटेर फल फल्ने क्षमता बढाउनुहोस्।"
  },
  {
    "crop": "Cauli",
    "tip":
        "Plant cauliflower in cool seasons. Apply nitrogen fertilizer in two split doses and ensure regular watering during early growth stages.",
    "tip_np":
        "काउली चिसो मौसममा रोप्नुपर्छ। नाइट्रोजन मल दुई चरणमा हाल्नुहोस् र अंकुरणको समयमा नियमित सिँचाइ गर्नुहोस्।"
  },
  {
    "crop": "Chilli",
    "tip":
        "Grow chilli in well-drained soil with full sun. Avoid waterlogging and regularly inspect for aphids, whiteflies, and mites.",
    "tip_np":
        "रातो खुर्सानी घाम राम्रो लाग्ने र पानीको निकास भएको माटोमा लगाउनुहोस्। पानी जम्न नदिनुहोस् र कीरा–फट्यांग्राको निगरानी गर्नुहोस्।"
  },
  {
    "crop": "Potato",
    "tip":
        "Use healthy, disease-free seed tubers. Plant in ridges for better aeration and apply balanced fertilizers at regular intervals.",
    "tip_np":
        "रोग नलागेका तन्दुरुस्त बीउ प्रयोग गर्नुहोस्। राम्रो हावा आवतजावतका लागि उठेको बेडमा रोप्नुहोस् र समयमा मल हाल्नुहोस्।"
  },
  {
    "crop": "Strawberry",
    "tip":
        "Use mulch to protect strawberries from rotting. Adopt drip irrigation and provide enough spacing between plants.",
    "tip_np":
        "स्ट्रबेरीलाई बिग्रनबाट जोगाउन मल्चिङ गर्नुहोस्। टप्का सिँचाइ प्रणाली प्रयोग गर्नुहोस् र बिरुवाबीच पर्याप्त दूरी राख्नुहोस्।"
  },
  {
    "crop": "Tomato",
    "tip":
        "Stake tomato plants for support and apply mulch to retain soil moisture. Watch for blight and other fungal diseases.",
    "tip_np":
        "टमाटरका बोटलाई सहारा दिन बाँध्ने गर्नुहोस्। जमिनको भिजाइ कायम राख्न मल्च प्रयोग गर्नुहोस् र ढुसीको निगरानी गर्नुहोस्।"
  },
];


  final List<String> cityOptions = [
    'Current Location',
    'Kathmandu',
    'Pokhara',
    'Biratnagar',
    'Butwal',
    'Lalitpur',
    'Dharan'
  ];

  @override
  void initState() {
    super.initState();
    isNepali = widget.isNepali;
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    const apiKey = 'fcf0b3512521420396e85751241809';
    String query = '';

    try {
      if (selectedCity == 'Current Location') {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) throw Exception('Location services disabled');

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) throw Exception('Permission denied');
        }
        if (permission == LocationPermission.deniedForever) throw Exception('Permission permanently denied');

        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        query = '${position.latitude},${position.longitude}';
      } else {
        query = selectedCity;
      }

      final url =
          'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$query&lang=${isNepali ? 'ne' : 'en'}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) throw Exception('API Error');

      final data = jsonDecode(response.body);
      final temp = data['current']['temp_c'];
      final desc = data['current']['condition']['text'];
      final city = data['location']['name'];
      final region = data['location']['region'];
      final country = data['location']['country'];
      final locationText = isNepali
          ? '📍 स्थान: $city, $region, $country'
          : '📍 Location: $city, $region, $country';

      setState(() {
        _weather = isNepali
            ? '$locationText\n🌤️ तापक्रम: ${temp}°C\n$desc'
            : '$locationText\n🌤️ Temperature: ${temp}°C\n$desc';
        _isLoadingWeather = false;
      });
    } catch (_) {
      setState(() {
        _weather = isNepali ? 'माफ गर्नुहोस्, मौसम ल्याउन सकिएन।' : 'Sorry, failed to load weather.';
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _takePhotoAndSendToUploadScreen() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UploadScreen(
            cropName: isNepali ? 'चिनिने बाली' : 'Guessed Crop',
            isNepali: isNepali,
            image: image,
          ),
        ),
      );
    }
  }

  Widget buildWeatherBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isNepali ? 'आजको मौसम' : 'Today\'s Weather',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              DropdownButton<String>(
                value: selectedCity,
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white),
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    selectedCity = value!;
                    _isLoadingWeather = true;
                  });
                  fetchWeather();
                },
                items: cityOptions.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _isLoadingWeather
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Text(_weather, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  Widget buildCropTipsCard() {
  return Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(top: 16),
    decoration: BoxDecoration(
      color: Colors.white12,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isNepali ? 'कृषि को सल्लाह' : 'Crop Cultivation Tips',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cropTips.map((item) {
                final crop = item['crop']!;
                final tip = isNepali ? item['tip_np']! : item['tip']!;
                final fileName = crop.toLowerCase() == 'potato'
                    ? 'potato.jpeg'
                    : '${crop.toLowerCase()}.png';

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(crop),
                        content: Text(tip),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          )
                        ],
                      ),
                    ),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Image.asset(
                                'assets/images/$fileName',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          Text(
                            crop,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        )
      ],
    ),
  );
}


  Widget buildDiagnosisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            isNepali ? 'बिरुवाको समस्या?' : 'Plant Problems?',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            isNepali
                ? 'बिरुवाको स्वास्थ्यका लागि उत्तम समाधान पत्ता लगाउनुहोस्।'
                : 'Find the best solutions for plant health!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Column(
                children: [
                  Icon(Icons.eco, size: 40, color: Colors.green),
                  SizedBox(height: 4),
                  Text('Identify Problem', style: TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
              Icon(Icons.arrow_forward, color: Colors.white70),
              Column(
                children: [
                  Icon(Icons.search, size: 40, color: Colors.blueAccent),
                  SizedBox(height: 4),
                  Text('Get Solution', style: TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UploadScreen(
                    cropName: isNepali ? 'चिनिने बाली' : 'Guessed Crop',
                    isNepali: isNepali,
                  ),
                ),
              );
            },
            child: Text(isNepali ? 'फोटो अपलोड गर्नुहोस्' : 'Upload Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isNepali ? 'गृह पृष्ठ' : 'Home';

    return Scaffold(
      backgroundColor: const Color(0xFF2c5364),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f2027),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isNepali = !isNepali;
                _isLoadingWeather = true;
              });
              fetchWeather();
            },
            child: Text(isNepali ? 'ENGLISH' : 'नेपाली', style: const TextStyle(color: Colors.white)),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'logout':
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginSignupPage()),
                    (route) => false,
                  );
                  break;
                case 'about':
                  showAboutDialog(
                    context: context,
                    applicationName: 'AgroCare',
                    applicationVersion: '1.0.0',
                    children: [Text(isNepali ? 'यो एप किसानहरूको लागि हो।' : 'This app is built for farmers.')],
                  );
                  break;
                case 'history':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HistoryScreen(isNepali: isNepali)),
                  );
                  break;
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'logout', child: Text(isNepali ? 'लगआउट' : 'Logout')),
              PopupMenuItem(value: 'about', child: Text(isNepali ? 'एपको बारेमा' : 'About')),
              PopupMenuItem(value: 'history', child: Text(isNepali ? 'इतिहास' : 'History')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildWeatherBox(),
            buildDiagnosisCard(),
            buildCropTipsCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePhotoAndSendToUploadScreen,
        backgroundColor: Colors.teal,
        shape: const StadiumBorder(),
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}
