import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LiveLocationMap(),
    );
  }
}

class LiveLocationMap extends StatefulWidget {
  const LiveLocationMap({super.key});

  @override
  _LiveLocationMapState createState() => _LiveLocationMapState();
}

class _LiveLocationMapState extends State<LiveLocationMap> {
  LatLng? currentLocation; // Variable to store current location
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    fetchCurrentLocation();
  }

  Future<void> fetchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Location services are disabled."),
      ));
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Location permissions are denied."),
        ));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Location permissions are permanently denied."),
      ));
      return;
    }

    // Fetch the current position using the LocationAccuracy argument
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high, // Use LocationAccuracy here
    );

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });

    // Center the map on the current location
    if (currentLocation != null) {
      mapController.move(currentLocation!, 15.0);
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Live Location Map with Marker'),
    ),
    body: Stack(
      children: [
        // Map container
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: currentLocation ?? const LatLng(0, 0),
            zoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            if (currentLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentLocation!,
                    builder: (ctx) => const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  ),
                ],
              ),
          ],
        ),
        if (currentLocation == null)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: fetchCurrentLocation,
      child: const Icon(Icons.location_searching),
    ),
  );
}

}
