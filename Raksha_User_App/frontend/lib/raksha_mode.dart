import 'dart:convert';
import 'package:RAKSHA/SOS/sos_active.dart';
import 'package:RAKSHA/camera.dart';
import 'package:RAKSHA/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RakshaModePage extends StatelessWidget {
  const RakshaModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NotificationDemo(),
    );
  }
}

class NotificationDemo extends StatefulWidget {
  const NotificationDemo({super.key});

  @override
  _NotificationDemoState createState() => _NotificationDemoState();
}

class _NotificationDemoState extends State<NotificationDemo> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late Timer _timer;
  bool _showPopup = false;
  bool _isRakshaModeActive = true; // Raksha mode toggle state
  int _intervalInSeconds = 10; // Default interval
  String _threatType = "Harrasment or Eve Teasing"; // Default threat type
  final ImagePicker _picker = ImagePicker();
  // String _threatType = "Domestic Violence"; // Default value

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    startTimer();
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String status) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Safety Status: $status',
      'User has marked their status as $status.',
      platformChannelSpecifics,
    );
  }

  void startTimer() {
    _timer =
        Timer.periodic(Duration(seconds: _intervalInSeconds), (timer) async {
      await handlePopUpAndNotification();
    });
  }

  Future<void> handlePopUpAndNotification() async {
    if (!_isRakshaModeActive) {
      return; // Skip notifications if Raksha Mode is off
    }

    setState(() {
      _showPopup = true;
    });

    await showNotification(_threatType);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateInterval(int seconds) {
    setState(() {
      _intervalInSeconds = seconds;
      _timer.cancel();
      startTimer();
    });
  }

  void _updateThreatType(String type) {
    setState(() {
      _threatType = type;
    });
  }

  Future<void> _getThreatType() async {
    // Example: Save selections to console or replace this with actual save logic

    // Example for persistent storage:
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('threatType', _threatType);
    print("Threat Type: $_threatType");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RAKSHA Mode'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          },
        ),
        actions: [
          Switch(
            value: _isRakshaModeActive,
            onChanged: (value) {
              setState(() {
                _isRakshaModeActive = value;
              });

              if (!value) {
                _timer.cancel();
              } else {
                startTimer();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // The map view
          const LiveLocationMap(),
          Positioned(
            bottom: 25,
            left: 20,
            right: 5,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DropdownButton<int>(
                      value: _intervalInSeconds,
                      onChanged: (value) {
                        if (value != null) _updateInterval(value);
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 10,
                          child: Text("10 Seconds"),
                        ),
                        DropdownMenuItem(
                          value: 15,
                          child: Text("15 Seconds"),
                        ),
                        DropdownMenuItem(
                          value: 30,
                          child: Text("30 Seconds"),
                        ),
                        DropdownMenuItem(
                          value: 60,
                          child: Text("1 Minutes"),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: _threatType,
                      onChanged: (value) {
                        if (value != null) _updateThreatType(value);
                      },
                      items: const [
                        DropdownMenuItem(
                          value: "Harrasment or Eve Teasing",
                          child: Text("Harrasment or Eve Teasing"),
                        ),
                        DropdownMenuItem(
                          value: "Stalking or Chasing",
                          child: Text("Stalking or Chasing"),
                        ),
                        DropdownMenuItem(
                          value: "Groping",
                          child: Text("Groping"),
                        ),
                        DropdownMenuItem(
                          value: "Snatching",
                          child: Text("Snatching"),
                        ),
                        DropdownMenuItem(
                          value: "Travelling Alone",
                          child: Text("Travelling Alone"),
                        ),
                        DropdownMenuItem(
                          value: "Domestic Violence",
                          child: Text("Domestic Violence"),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        _getThreatType();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SosActiveScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          height: 3,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CameraApp(),
                          ),
                        );
                      },
                      child: const Text(
                        'Camera',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          height: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_showPopup) _showPopupWidget(),
        ],
      ),
    );
  }

  Future<void> _showPinDialog(BuildContext context) {
    final TextEditingController pinController = TextEditingController();
    bool isSubmitting = false;
    bool isPinCorrect = false;
    String message = '';
    int attemptCount = 0;

    void verifyPinCallback(String pin, void Function(bool) onResult) {
      SharedPreferences.getInstance().then((prefs) {
        String user = prefs.getString('username') ?? 'Guest';
        http
            .post(
          Uri.parse('http://192.168.93.176:5000/security/$user'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'securityPin': pin}),
        )
            .then((response) {
          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            onResult(responseData['isValid'] == true);
          } else {
            onResult(false);
          }
        }).catchError((error) {
          debugPrint('Error verifying PIN: $error');
          onResult(false);
        });
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Enter Security PIN'),
              content: isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isPinCorrect)
                          TextField(
                            controller: pinController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            decoration: const InputDecoration(
                              labelText: 'PIN',
                            ),
                          ),
                        const SizedBox(height: 13),
                        if (message.isNotEmpty)
                          Text(
                            message,
                            style: TextStyle(
                              color: isPinCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                      ],
                    ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          String pin = pinController.text.trim();

                          if (pin.length == 4) {
                            setState(() {
                              isSubmitting = true;
                              message = '';
                            });

                            verifyPinCallback(pin, (isValid) {
                              setState(() {
                                isSubmitting = false;
                                isPinCorrect = isValid;
                                message = isValid
                                    ? 'PIN is correct! You are safe.'
                                    : 'Invalid PIN. Try again.';
                                attemptCount++;
                              });

                              if (isValid) {
                                Navigator.of(context).pop(); // Close dialog
                                showNotification('Safe');
                                startTimer();
                              } else if (attemptCount >= 3) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SosActiveScreen(),
                                  ),
                                );
                              }
                            });
                          } else {
                            setState(() {
                              message = 'Please enter a valid 4-digit PIN.';
                            });
                          }
                        },
                  child: const Text('Submit'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );

    return Future.value();
  }

  Widget _showPopupWidget() {
    return Positioned(
      bottom: 135,
      left: 30,
      right: 30,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you safe?',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showPinDialog(context);
                      showNotification('Safe');
                      setState(() {
                        _showPopup = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      'I am Safe',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _getThreatType();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SosActiveScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      'I am in Danger',
                      style: TextStyle(color: Colors.white),
                    ),
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

//camera chalu karoo

class LiveLocationMap extends StatefulWidget {
  const LiveLocationMap({super.key});

  @override
  _LiveLocationMapState createState() => _LiveLocationMapState();
}

class _LiveLocationMapState extends State<LiveLocationMap> {
  LatLng? currentLocation; // Variable to store current location
  final MapController mapController = MapController();
  List<LatLng> dynamicZones = [
    LatLng(20.7749, 78.4194), // Example dynamic zone
    LatLng(22.0522, 78.2437), // Example dynamic zone
  ];

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  Future<void> _startLocationUpdates() async {
    // Check location services and permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled.")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions are denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Location permissions are permanently denied.")),
      );
      return;
    }

    // Start listening to location changes
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Minimum distance (in meters) before updates
      ),
    ).listen((Position position) {
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Center the map on the updated location
      if (currentLocation != null) {
        mapController.move(currentLocation!, mapController.zoom);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location Map'),
      ),
      body: Stack(
        children: [
          // Map container
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: currentLocation ?? LatLng(0, 0),
                zoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                if (currentLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentLocation!,
                        builder: (ctx) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withOpacity(0.8),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: const Icon(
                            Icons
                                .directions_walk, // Custom symbol for live location
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                // Dynamic zone circles
                CircleLayer(
                  circles: dynamicZones.map((point) {
                    return CircleMarker(
                      point: point,
                      color: Colors.red.withOpacity(0.5),
                      borderColor: Colors.red,
                      borderStrokeWidth: 2,
                      radius: 500.0, // Radius in meters
                      useRadiusInMeter: true,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
