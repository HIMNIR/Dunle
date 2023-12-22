import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dulnne/lib/nearby.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());
  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return MaterialApp(home: GetStarted());
    }
  }
class GetStarted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // This aligns the children of the column in the center of the available space
          children: [
            Image.asset(
              'assets/icons/logo.png',
              height: 350,
              width: 300,
              fit: BoxFit.cover,
            ),
            const SizedBox(
              height:50,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    Home()
                ),
                );
                // Respond to button press

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent, // This is the color of the button
                foregroundColor: Colors.white, // This is the color of the text
                minimumSize: const Size.fromHeight(40), // This sets the minimum width of the button to 200 pixels
              ),
              child: const Text('Get Started'),

            )

          ],

        ),
      ),
    );
  }
}
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();

}

class _HomeState extends State<Home> {

  GoogleMapController? _mapController;
  LatLng _currentPosition = LatLng(0.0, 0.0); // Initialize with a default value
  List<Marker> _markers = [];
  List<String> _hotelNames = [];

  void _getCurrentLocation() async {
    try {
      LocationPermission permission;
      permission = await Geolocator.requestPermission();
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _loadNearbyHotelsNames();
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }
  void _loadNearbyHotelsNames() async {
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
  void loadCells(){
    for(int i = 0;i<=_hotelNames.length;i++)
      {
        PersonContainer(name: _hotelNames[i], pictureUrl: 'assets/icons/icon.png', distance: 12);
      }
}

  int _currentIndex = 0;
  List<Widget> _bodywidgets = [
    HomePage(),
   Nearby(),
    Favourites(),
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(

        body: _bodywidgets[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon:Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wifi_tethering_sharp),
              activeIcon:Icon(Icons.wifi_tethering),
              label: 'Nearby',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon:Icon(Icons.favorite),
              label: 'Favourites',
            ),
          ],elevation: 20.0,
        ),
      ),
    );
  }
}
class HomePage extends StatelessWidget {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(27.708498299594176, 85.32518765000657);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 12.3,
        ),
      ),
    );
  }
}

class PersonContainer extends StatefulWidget {
  final String name;
  final String pictureUrl;
  final double distance;

  const PersonContainer({
    required this.name,
    required this.pictureUrl,
    required this.distance,
  });

  @override
  State<PersonContainer> createState() => _PersonContainerState();
}

class _PersonContainerState extends State<PersonContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 500,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50.0),

          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.distance.toStringAsFixed(2)} km',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Nearby extends StatelessWidget {
  GoogleMapController? _mapController;
  LatLng _currentPosition = LatLng(0.0, 0.0); // Initialize with a default value
  List<String> _hotelNames = [];

  void _getCurrentLocation() async {
    try {
      LocationPermission permission;
      permission = await Geolocator.requestPermission();
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
        _currentPosition = LatLng(position.latitude, position.longitude);
        _loadNearbyHotelsNames();
    } catch (e) {
      print('Error getting location: $e');
    }
  }
  Future<void> _loadNearbyHotelsNames() async {
    try {
      LocationPermission permission;
      permission = await Geolocator.requestPermission();
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = LatLng(position.latitude, position.longitude);
      _loadNearbyHotelsNames();
    } catch (e) {
      print('Error getting location: $e');
    }
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
          _hotelNames = hotelNames;
      }
    } else {
      print('Failed to load nearby hotels');
    }
  }
  @override
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadNearbyHotelsNames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (_hotelNames.isNotEmpty) {
            // Build the PersonContainer widgets
            List<Widget> personContainers = [];
            for (int a = 1; a < _hotelNames.length; a++) {
              personContainers.add(
                PersonContainer(
                  name: _hotelNames[a],
                  pictureUrl: 'assets/icons/icon.png',
                  distance: 12,
                ),
              );
            }
            return SingleChildScrollView(
              child: Column(
                children: personContainers,
              ),
            );
          } else {
            return Center(
              child: Text('No nearby hotels found'),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   _loadNearbyHotelsNames();
  //   for (int a = 1; a < _hotelNames.length; a++) {
  //     PersonContainer here = PersonContainer(
  //       name: _hotelNames[a],
  //       pictureUrl: 'assets/icons/icon.png',
  //       distance: 12,
  //     );
  //     return here;
  //   }
  //   return PersonContainer(
  //     name: _hotelNames[1],
  //     pictureUrl: 'assets/icons/icon.png',
  //     distance: 12,
  //   );
  // }
}

class Favourites extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Favourites"),
    );
  }
}



