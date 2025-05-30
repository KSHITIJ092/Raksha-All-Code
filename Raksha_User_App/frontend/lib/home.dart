import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'raksha_mode.dart';
import 'package:RAKSHA/SOS/sos_active.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const WomenSafetyApp());
}

class WomenSafetyApp extends StatelessWidget {
  const WomenSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool isRakshaModeActive = false;
  int _selectedIndex = 0;
  bool hasError = false;
  late Map<String, dynamic> userDetails;
  List<dynamic> emergencyDetails = [];
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    fetchUserDetails();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const UserDetailsPage(userId: '')),
        );
        break;
    }
  }

  Future<void> fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('username') ?? 'Guest';

    // final url = 'http://192.168.1.176:5000/api/personalinfo/$user';
    // final url = 'http://localhost:5000/api/personalinfo/$user';
    final url = 'http://192.168.93.176:5000/api/personalinfo/$user';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          userDetails = json.decode(response.body);
          emergencyDetails = userDetails['emergencyContacts'] ?? [];
        });
      } else {
        setState(() {
          hasError = true;
        });
      }
    } catch (error) {
      setState(() {
        hasError = true;
      });
      print("Error fetching data: $error");
    }
  }

  // Updated _makePhoneCall method to use MethodChannel
  Future<void> _makePhoneCall(String number) async {
    final PermissionStatus permissionStatus = await Permission.phone.request();

    if (permissionStatus.isGranted) {
      try {
        const platform = MethodChannel(
            'com.example.calls'); // Ensure it matches your Kotlin implementation
        await platform.invokeMethod('makeCall', {'number': number});
      } catch (e) {
        print('Error occurred while trying to call $number: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to make a call to $number')),
        );
      }
    } else {
      // Show permission denied dialog
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

  Widget _buildEmergencyContact(String number, String name) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.orange.shade300,
          child: Text(
            name[0], // Display the first letter of the name
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          number,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.green),
          onPressed: () {
            _makePhoneCall(number); // Calling the updated method
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/img.jpg'),
              radius: 20,
            ),
            SizedBox(width: 10),
            Text(
              'RAKSHA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 26,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RAKSHA MODE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  Transform.scale(
                    scale: 1.2,
                    child: Switch(
                      value: isRakshaModeActive,
                      onChanged: (value) {
                        setState(() {
                          isRakshaModeActive = value;
                        });

                        if (isRakshaModeActive) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RakshaModePage(),
                            ),
                          );
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isRakshaModeActive
                                  ? "RAKSHA Mode Activated!"
                                  : "RAKSHA Mode Deactivated!",
                            ),
                            duration: const Duration(milliseconds: 800),
                          ),
                        );
                      },
                      activeColor: Colors.red,
                      activeTrackColor: Colors.red.shade100,
                      inactiveTrackColor: Colors.grey.shade400,
                      inactiveThumbColor: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SosActiveScreen(),
                    ),
                  );
                },
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Colors.orange, Colors.red],
                          center: Alignment.center,
                          radius: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            spreadRadius: 10,
                            color: Colors.orange.withOpacity(0.7),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'EMERGENCY CONTACTS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              emergencyDetails.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: emergencyDetails.length,
                      itemBuilder: (context, index) {
                        final contact = emergencyDetails[index];
                        return _buildEmergencyContact(
                          contact['phone'], // Use 'phone' for the number field
                          contact['name'],
                        );
                      },
                    )
                  : Text(
                      'No emergency contacts added',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, color: Colors.black),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
