import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
LatLng _currentPosition = const LatLng(0.0, 0.0); // Initialize with a default value
List<String> _hotelNames = [];
List<LatLng> _DistanceTill = [];
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
                const Home()
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
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();

}

class _HomeState extends State<Home> {

  int _currentIndex = 0;
  final List<Widget> _bodywidgets = [
    HomePage(),
    Nearby(),
    const Favourites(),
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
          items: const [
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

  HomePage({super.key});

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
  final int noOnList;

  const PersonContainer({super.key,
    required this.name,
    required this.pictureUrl,
    required this.distance,
    required this.noOnList,
  });

  @override
  State<PersonContainer> createState() => _PersonContainerState();
}
class _PersonContainerState extends State<PersonContainer> {
  bool _isFavourited = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 500,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/bg.png'),
          fit: BoxFit.cover,
        ),
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: Image.network(
                  widget.pictureUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0), // Add space above the text
                      child: Flexible(
                        child: Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen(currentLocation: _currentPosition, destination: _DistanceTill[widget.noOnList], onList: widget.noOnList)));
                      },

                      child: Text('View on Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent, // background color
                        foregroundColor: Colors.white, // text color
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("Rating:")
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: -15,
            left: 25,
            child: IconButton(
              icon: Icon(_isFavourited ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                setState(() {
                  _isFavourited = !_isFavourited;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Nearby extends StatelessWidget {

  List<String> _imgRef = [];
  List<double> Distance =[];
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
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
    }
    const apiKey = "AIzaSyCJt0Gi-AmWfrOIsJfG9ruO6DiqkIBxV8I";
    const radius = 2000; // 2 km
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentPosition.latitude},${_currentPosition.longitude}&radius=$radius&type=tourist_attraction&key=$apiKey',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final List<String> hotelNames = List<String>.from(data['results'].map((place) => place['name']));
        final List<LatLng> distanceTill = List<LatLng>.from(data['results'].map((place) => LatLng(place['geometry']['location']['lat'], place['geometry']['location']['lng']), ));
        // Assuming data is a Map<dynamic, dynamic>
        final List<String> imgRefs = List<String>.from(data['results'].map((place) {
          final photos = place['photos'] as List?;
          if (photos != null && photos.isNotEmpty) {
            final photoReference = photos[0]['photo_reference'];

            if (photoReference != null) {
              return photoReference as String;
            }
          }
          // Return a default value or handle the case where there's no valid photo_reference
          return 'AWU5eFhMPJjdl0E2T3WVbzx8xVwJiT33n4YwSL63QBcedseWAp2cbIpyb3_2uxjGAV41BHmXDmzprdy71EuG3LfbgOlaoU0rM64LDdXHY1Xep08FTMLRVT56nWNfii7IcjfXnGOgk3zlvhW52hVY3Phg7Xb8EDtph57iCDintkr6MY8AhDkr';
        }));

        // for (var place in data['results']) {
        //   if (place.containsKey('photos') &&
        //       place['photos'] is List &&
        //       place['photos'].isNotEmpty) {
        //     // Iterate through the photos and get the photo_reference
        //     for (var photo in place['photos']) {
        //       imgRefs.add(photo['photo_reference']);
        //     }
        //   } else {
        //     // Handle the case where 'photos' is absent or empty
        //     imgRefs.add('AWU5eFhgzyOZLt77H38RvhoXarH-VJ-c0u8RaQs3-LtQ6dRpUa2YTG_wtc0uA28wrPhcj7mzrqZKi642M3E9xKkKh5o3A3BNUto0Ho8wokpIaX2_NPmcFVjMfaKXZPI5WtXQ3jfmwlpXzytQV8F0m2WLUBzCNSXTs4iFPGq_tyTSCI5QwNWr');
        //   }
        // }
        Distance = distanceTill.map((latLng) {
          return calculateDistance(latLng.latitude, latLng.longitude);
        }).toList();
        _imgRef = imgRefs;
        _DistanceTill = distanceTill;
        _hotelNames = hotelNames;
      }
    } else {
      print('Failed to load nearby hotels');
    }

  }

  @override
  Widget build(BuildContext context ) {
    return FutureBuilder(
      future: _loadNearbyHotelsNames(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (_hotelNames.isNotEmpty) {
            // Build the PersonContainer widgets
            List<Widget> personContainers = [];
            for (int a = 0; a < _hotelNames.length; a++) {
              personContainers.add(
                PersonContainer(
                  name: _hotelNames[a],
                  pictureUrl: 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=200&photoreference=${_imgRef[a]}&key=AIzaSyCJt0Gi-AmWfrOIsJfG9ruO6DiqkIBxV8I',
                  distance: Distance[a],
                  noOnList: a,
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
              child: Text("No Internet Connection"),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}


class MapScreen extends StatefulWidget {
  final LatLng currentLocation;
  final LatLng destination;
  final int onList;

  MapScreen({required this.currentLocation,required this.destination,required this.onList});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  double totalDistance = 0;

  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyCJt0Gi-AmWfrOIsJfG9ruO6DiqkIBxV8I";

  @override
  void initState() {
    super.initState();

    /// origin marker
    _addMarker(LatLng(widget.currentLocation.latitude, widget.currentLocation.longitude), "origin",
        BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(LatLng(widget.destination.latitude, widget.destination.longitude), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));
    _getPolyline();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(_hotelNames[widget.onList]),
          ),
          body:Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: LatLng(widget.currentLocation.latitude, widget.currentLocation.longitude), zoom: 15),
                myLocationEnabled: true,
                tiltGesturesEnabled: true,
                compassEnabled: true,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                onMapCreated: _onMapCreated,
                markers: Set<Marker>.of(markers.values),
                polylines: Set<Polyline>.of(polylines.values),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.25, // Start half-open
                minChildSize: 0.2, // Allow partial closing
                maxChildSize: 0.5, // Allow full expansion
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0,-5),
                          blurRadius: 15,
                        )
                      ]
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.all(25),
                      children: [
                        SizedBox(height: 15),
                    Text(
                    "Additional Info on ${_hotelNames[widget.onList]}",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                      SizedBox(height: 15),
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.place_outlined,color: Colors.blue),
                              SizedBox(width: 10),
                              Text("Distance to travel: ${totalDistance.toStringAsFixed(2)} km",
                                style: TextStyle(
                                    fontSize: 18),
                              )],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.directions_walk,color: Colors.orange),
                              SizedBox(width: 10),
                              Text("Time estimated by foot: ${(totalDistance /
                                  2).toStringAsFixed(2)}hrs",
                                style: TextStyle(
                                    fontSize: 18),
                              )],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.motorcycle_outlined, color: Colors.orange),
                              SizedBox(width: 10),
                              Text("Time estimated by Vehicle: ${(totalDistance / 25).toStringAsFixed(2)}hrs",
                              style: TextStyle(
                                fontSize: 18
                              ),),
                            ],
                          )
                        ],
                      )
                      ],
                    ),
                  );
                },
              )
            ],
          )
      ),

    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
    Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.green, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(widget.currentLocation.latitude, widget.currentLocation.longitude),
        PointLatLng(widget.destination.latitude, widget.destination.longitude),
        travelMode: TravelMode.walking,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        List<PointLatLng> points = result.points;
        for (int i = 0; i < points.length - 1; i++) {
          // Use a suitable library for distance calculation, such as 'geolocator'
          double pointDistance = Geolocator.distanceBetween(
            points[i].latitude,
            points[i].longitude,
            points[i + 1].latitude,
            points[i + 1].longitude,
          );
          totalDistance += pointDistance;
        }
        totalDistance = totalDistance/1000;
      });
    }
    _addPolyLine();
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