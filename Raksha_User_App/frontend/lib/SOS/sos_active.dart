import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:geocoding/geocoding.dart'; // For reverse geocoding
import 'package:flutter_background_messenger/flutter_background_messenger.dart';

class SosActiveScreen extends StatefulWidget {
  const SosActiveScreen({super.key});

  @override
  _SosActiveScreenState createState() => _SosActiveScreenState();
}

class _SosActiveScreenState extends State<SosActiveScreen>
    with SingleTickerProviderStateMixin {
  String location = "Fetching location...";
  late AnimationController _animationController;
  late Animation<double> _waveAnimation;
  bool isLoading = true;
  bool hasError = false;
  late Map<String, dynamic> userDetails;
  late IO.Socket socket;
  // final List<String> _emergencyContacts = [
  //   '9156979741',
  //   '8591378405',
  //   "8329527499",
  //   "8591237365"
  // ];

  late List<String> _emergencyContacts;
  late FlutterBackgroundMessenger _messenger;

  @override
  void initState() {
    super.initState();
    _messenger = FlutterBackgroundMessenger();
    initializeSocket();
    _getCurrentLocation();
    _initializeAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void initializeSocket() {
    socket = IO.io(
      'http://192.168.93.176:3000', // Replace with your socket server URL
      IO.OptionBuilder()
          .setTransports(['websocket']) // Specify transport protocol
          .build(),
    );

    socket.onConnect((_) {
      print('Connected to socket server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from socket server');
    });
  }

  void _initializeAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
    _waveAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  void _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => location = "Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => location = "Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => location = "Location permission permanently denied.");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Convert coordinates to a human-readable address
      await _getAddressFromCoordinates(position.latitude, position.longitude);
      fetchUserDetails(position.latitude, position.longitude);
      _sendSOSMessage();
    } catch (e) {
      setState(() => location = "Unable to fetch location.");
    }
  }

  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        setState(() {
          location =
              "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      } else {
        setState(() {
          location = "No address found for the location.";
        });
      }
    } catch (e) {
      setState(() {
        location = "Error fetching address.";
      });
    }
  }

  Future<void> fetchUserDetails(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('username') ?? 'Guest';
    final threatType = prefs.getString('threatType');

    final url = 'http://192.168.93.176:5000/api/personalinfo/$user';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        userDetails = json.decode(response.body);
        isLoading = false;
        print(userDetails);
        if (userDetails['emergencyContacts'] != null) {
          print(userDetails['emergencyContacts']);
          _emergencyContacts =
              (userDetails['emergencyContacts'] as List<dynamic>)
                  .map((contact) =>
                      contact['phone'].toString()) // Convert phone to string
                  .toList();
        }

        // Emit data to socket server
        socket.emit('userDetails', {
          'username': user,
          'latitude': latitude,
          'longitude': longitude,
          'details': userDetails,
          "threatType": threatType
        });

        print('User details and location sent to socket server.');
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.white,
                title: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Alert Sent',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
                content: Text(
                  'The SOS alert has been sent to the server and Help is on the Way!!!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.green[700],
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          }
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      print("Error fetching data: $error");
    }
  }

  Future<Position> _getLiveLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _sendSOSMessage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final threatType = prefs.getString('threatType');

      final position = await _getLiveLocation();
      final latitude = position.latitude;
      final longitude = position.longitude;
      final locationMessage =
          'SOS ! I need help. . Threat Type: $threatType. My location: http://maps.google.com/?q=$latitude,$longitude';

      for (var number in _emergencyContacts) {
        final success = await _messenger.sendSMS(
          phoneNumber: number,
          message: locationMessage,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('SOS message sent to $number.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send SOS to $number.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending SOS: $e')),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final PermissionStatus permissionStatus = await Permission.phone.request();

    if (permissionStatus.isGranted) {
      try {
        const platform = MethodChannel('com.example.calls');
        await platform.invokeMethod('makeCall', {'number': phoneNumber});
      } catch (e) {
        print('Error occurred while trying to call $phoneNumber: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to make a call to $phoneNumber')),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text(
              'Phone call permission is required to make emergency calls.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS MODE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
                child: ScaleTransition(
                  scale: _waveAnimation,
                  child: GestureDetector(
                    onTap: () {
                      print('SOS Button Pressed!');
                    },
                    child: Container(
                      width: 210,
                      height: 210,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD31010), Color(0x88FF0707)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEA7676).withOpacity(1),
                            spreadRadius: 20,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          for (double radius in [160, 110, 70])
                            Container(
                              width: radius,
                              height: radius,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                          const Center(
                            child: Text(
                              "SOS Activated",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "Current Location",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        location,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Column(
                children: [
                  SosActionButton(
                    label: "Call Police",
                    icon: Icons.local_police,
                    color: const Color(0xFFE9C914),
                    onTap: () => _makePhoneCall("100"),
                  ),
                  const SizedBox(height: 16),
                  SosActionButton(
                    label: "Call Ambulance",
                    icon: Icons.local_hospital,
                    color: const Color(0xFFF764EF),
                    onTap: () => _makePhoneCall("102"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SosActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const SosActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
