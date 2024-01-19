# dulnne

# Travel Companion App

Welcome to the Travel Companion app, a Flutter-based mobile application designed to enhance your travel experience. This app provides features to explore nearby tourist attractions, view details about them, and navigate to your chosen destination efficiently.

Getting Started
Installation:

Make sure you have Flutter installed. If not, follow the official Flutter installation guide.
Clone the repository: git clone [repository_url]
Navigate to the project directory: cd travel_companion_app
Dependencies:

Install project dependencies by running: flutter pub get
Run the App:

Connect your device or start an emulator.
Run the app: flutter run
Features
1. Get Started
Upon launching the app, click the "Get Started" button to enter the main interface.
2. Home Screen
Explore the main features of the app through the bottom navigation bar.
Navigate between the Home, Nearby, and Favourites screens.
3. Nearby
The "Nearby" screen fetches nearby tourist attractions using Google Places API.
Displays a list of attractions with details such as name, distance, and rating.
Click on "View on Map" to see the location on the map.
4. Map Screen
When viewing a location on the map, detailed information is provided in a draggable sheet.
Additional information includes distance, estimated walking time, and estimated vehicle time.
5. Favourites
Access your favorite locations through the "Favourites" screen.
Implementation Details
The app utilizes the Google Maps Flutter package for map integration.
Geolocator package is used to obtain the device's current location.
HTTP package handles communication with the Google Places API.
Flutter Polyline Points is employed to draw polylines on the map for route visualization.
Important Notes
Ensure that the device has an active internet connection for accurate location and data retrieval.
Google API key is required for fetching nearby locations and rendering maps. Please replace the placeholder API key in the code with a valid one.
