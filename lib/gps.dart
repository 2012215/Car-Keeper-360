import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class GpsTrackingPage extends StatefulWidget {
  @override
  _GpsTrackingPageState createState() => _GpsTrackingPageState();
}

class _GpsTrackingPageState extends State<GpsTrackingPage> {
  double? latitude;
  double? longitude;
  String status = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _fetchGpsData();
  }

  Future<void> _fetchGpsData() async {
    var url = Uri.parse('http://192.168.168.59:5000/get_gps_data'); // Replace with your Flask server IP
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        latitude = data['LAT'];
        longitude = data['LNG'];
        status = 'Latitude: $latitude, Longitude: $longitude';
      });
    } else {
      setState(() {
        status = 'Failed to fetch data';
      });
    }
  }

  void _openGoogleMaps() async {
    if (latitude != null && longitude != null) {
      final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else {
        setState(() {
          status = 'Could not open Google Maps.';
        });
      }
    } else {
      setState(() {
        status = 'No GPS data available.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPS Tracking'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (latitude != null && longitude != null)
                Text(
                  'Latitude: $latitude, Longitude: $longitude',
                  style: TextStyle(fontSize: 20),
                ),
              SizedBox(height: 20),
              Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              ElevatedButton(
                onPressed: _fetchGpsData,
                child: Text('Refresh'),
              ),
              ElevatedButton(
                onPressed: _openGoogleMaps,
                child: Text('Open in Google Maps'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
