import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // For reverse geocoding
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  List<dynamic> _places = [];
  bool _isLoading = false;
  String _selectedType = 'hospital'; // Default type
  Position? _currentPosition;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Fetch the current location and address
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
        ),
      );
      return;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied.'),
        ),
      );
      return;
    }

    // Fetch current position
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });

    // Fetch address for the current position
    _getAddressFromLatLng(position);
    _fetchNearbyPlaces();
  }

  // Reverse geocode to fetch address from latitude and longitude
  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _currentAddress =
              "${place.name}, ${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching address: $e')),
      );
    }
  }

  // Fetch Nearby Places from Overpass API
  Future<void> _fetchNearbyPlaces() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get current location.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final latitude = _currentPosition!.latitude;
      final longitude = _currentPosition!.longitude;

      String amenityFilter = '';
      if (_selectedType == 'hospital') {
        amenityFilter =
            'node["amenity"="hospital"](around:10000,$latitude,$longitude);';
      } else if (_selectedType == 'police') {
        amenityFilter =
            'node["amenity"="police"](around:10000,$latitude,$longitude);';
      } else if (_selectedType == 'ngo') {
        amenityFilter =
            'node["amenity"="social_facility"](around:10000,$latitude,$longitude);';
      }

      final String url =
          'https://overpass-api.de/api/interpreter?data=[out:json];($amenityFilter);out;';

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['elements'] != null) {
        setState(() {
          _places = data['elements'];
        });
      } else {
        throw Exception('Failed to fetch places');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching places: $error')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Service Type Button
  Widget _buildTypeButton(String type, IconData icon, Color color) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedType == type ? color : Colors.grey[300],
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 4,
      ),
      onPressed: () {
        setState(() {
          _selectedType = type;
        });
        _fetchNearbyPlaces();
      },
      icon: Icon(icon, color: _selectedType == type ? Colors.white : Colors.black),
      label: Text(
        type[0].toUpperCase() + type.substring(1),
        style: TextStyle(color: _selectedType == type ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Services'),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_currentAddress != null)
              Text(
                'Current Address: $_currentAddress',
                style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTypeButton('hospital', Icons.local_hospital, Colors.red),
                  const SizedBox(width: 12),
                  _buildTypeButton('police', Icons.local_police, Colors.blue),
                  const SizedBox(width: 12),
                  _buildTypeButton('ngo', Icons.volunteer_activism, Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.pinkAccent,
                        strokeWidth: 5,
                      ),
                    )
                  : _places.isEmpty
                      ? const Center(
                          child: Text(
                            'No results found within 10 km.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _places.length,
                          itemBuilder: (context, index) {
                            final place = _places[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: const Icon(Icons.location_on, color: Colors.pinkAccent, size: 30),
                                title: Text(
                                  place['tags']?['name'] ?? 'Unknown Place',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  place['tags']?['addr:street'] ?? 'No address available',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
