import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_places_flutter/google_places_flutter.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Locator',
      home: HotelLocator(),
    );
  }
}

class HotelLocator extends StatefulWidget {
  @override
  _HotelLocatorState createState() => _HotelLocatorState();
}

class _HotelLocatorState extends State<HotelLocator> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = LatLng(0.0, 0.0); // Initialize with a default value
  List<Marker> _markers = [];
  List<String> _hotelNames = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      LocationPermission permission;
      permission = await Geolocator.requestPermission();
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _loadNearbyHotels();
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }



  void _loadNearbyHotels() async {
    final apiKey = "AIzaSyCJt0Gi-AmWfrOIsJfG9ruO6DiqkIBxV8I";
    final radius = 2000; // 2 km
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentPosition.latitude},${_currentPosition.longitude}&radius=$radius&type=tourist_attraction&key=$apiKey',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final hotelNames = List<String>.from(data['results'].map((place) => place['name']));
        setState(() {
          _hotelNames = hotelNames;
        });
      }
    } else {
      print('Failed to load nearby hotels');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Hotel Locator'),
        ),
        body: ListView.builder(
          itemCount: _hotelNames.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_hotelNames[index]),
            );
          },
        )
    );
  }
}