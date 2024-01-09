import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: GetStarted());
  }
}

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/logo.png',
              height: 350,
              width: 300,
              fit: BoxFit.cover,
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(40),
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
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  final List<Widget> _bodywidgets = [
    HomePage(),
    Nearby(),
    const Favourites(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _bodywidgets,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wifi_tethering_sharp),
              activeIcon: Icon(Icons.wifi_tethering),
              label: 'Nearby',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favourites',
            ),
          ],
          elevation: 20.0,
        ),
      ),
    );
  }
}

// ... (PersonContainer, HomePage, and Favourites remain unchanged)

class Nearby extends StatelessWidget {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(0.0, 0.0);
  List<String> _hotelNames = [];
  List<double> _distanceTill = [];

  Nearby({super.key});

  double calculateDistance(double latitude, double longitude) {
    double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition.latitude,
        _currentPosition.longitude,
        latitude,
        longitude
    );
    return distanceInMeters;
  }

  Future<void> _loadNearbyHotelsNames() async {
    // ... (remaining code remains unchanged)
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder(
        future: _loadNearbyHotelsNames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_hotelNames.isNotEmpty) {
              List<Widget> personContainers = [];
              for (int a = 1; a < _hotelNames.length; a++) {
                personContainers.add(
                  PersonContainer(
                    name: _hotelNames[a],
                    pictureUrl: 'assets',
                    distance: _distanceTill[a],
                  ),
                );
              }
              return Column(
                children: personContainers,
              );
            } else {
              return Center(
                child: Text(_distanceTill.isNotEmpty ? _distanceTill[0].toString() : 'No data'),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class Favourites extends StatelessWidget {
  const Favourites({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Favourites"),
    );
  }
}
