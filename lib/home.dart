import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Login.dart';
import 'capture.dart';
import 'stream.dart';
import 'gps.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? userId;
  String message = '';

  void captureImage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FaceCaptureScreen()),
    );
  }

  void trainImages() async {
    var url = Uri.parse('http://192.168.168.206:5000/train_images');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        message = json.decode(response.body)['message'];
      });
    } else {
      setState(() {
        message = json.decode(response.body)['message'] ?? 'Error';
      });
    }
  }

  void recognizeFaces() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RealTimeRecognitionScreen()),
    );
  }

  void trackGps() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GpsTrackingPage()),
    );
  }
  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
          (Route<dynamic> route) => false,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: captureImage,
                child: Text('Capture Image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: trainImages,
                child: Text('Train Images'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: recognizeFaces,
                child: Text('Recognize Faces'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: trackGps,
                child: Text('GPS Track'),
              ),
              SizedBox(height: 20),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }
}
