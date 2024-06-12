import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RealTimeRecognitionScreen(),
    );
  }
}

class RealTimeRecognitionScreen extends StatefulWidget {
  @override
  _RealTimeRecognitionScreenState createState() => _RealTimeRecognitionScreenState();
}

class _RealTimeRecognitionScreenState extends State<RealTimeRecognitionScreen> {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  String processedImage = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _getUserMedia();
  }

  Future<void> _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': false,
      'video': {
        'facingMode': 'user',
      },
    };

    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = stream;
    _startFrameCapture();
  }

  void _startFrameCapture() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (_localRenderer.srcObject != null) {
        final videoTrack = _localRenderer.srcObject!.getVideoTracks().first;
        final frame = await videoTrack.captureFrame();
        await _processFrame(frame.asUint8List());
      }
    });
  }

  Future<void> _processFrame(Uint8List frameData) async {
    final response = await http.post(
      Uri.parse('http://192.168.168.206:5000/process_frame'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Encode(frameData)}),
    );

    if (response.statusCode == 200) {
      setState(() {
        processedImage = jsonDecode(response.body)['image'];
      });
    } else {
      print('Failed to process frame: ${response.body}');
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Face Recognition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {},
              child: Text('Start Recognition'),
            ),
            SizedBox(height: 20),
            // Small widget to display the video
            Container(
              width: 200,
              height: 150,
              child: RTCVideoView(_localRenderer),
              decoration: BoxDecoration(color: Colors.black54),
            ),
            if (processedImage.isNotEmpty)
              Image.memory(
                base64Decode(processedImage),
                width: 300,
                height: 200,
              ),
          ],
        ),
      ),
    );
  }
}

extension on ByteBuffer {
  Uint8List asUint8List() {
    return Uint8List.view(this);
  }
}
