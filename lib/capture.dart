import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FaceCaptureScreen(),
    );
  }
}

class FaceCaptureScreen extends StatefulWidget {
  @override
  _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  String? userId;
  String message = '';

  void captureImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter User ID'),
          content: TextField(
            onChanged: (value) {
              userId = value;
            },
            decoration: InputDecoration(hintText: 'User ID'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (userId != null && userId!.isNotEmpty) {
                  var url = Uri.parse('http://192.168.168.206:5000/capture_image');
                  var response = await http.post(
                    url,
                    headers: {"Content-Type": "application/json"},
                    body: json.encode({'userId': userId}),
                  );

                  if (response.statusCode == 200) {
                    setState(() {
                      message = json.decode(response.body)['message'];
                    });
                  } else {
                    setState(() {
                      message = json.decode(response.body)['message'] ?? 'Error';
                    });
                  }
                  Navigator.pop(context);
                } else {
                  setState(() {
                    message = 'User ID cannot be empty';
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Capture'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Capture App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: captureImage,
              child: Text('Capture Image'),
            ),
            SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}
