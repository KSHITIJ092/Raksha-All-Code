import 'dart:convert';
import 'dart:async';
import 'package:RAKSHA/SOS/sos_active.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:RAKSHA/screens/login_page.dart';

class UserDetailsPage extends StatefulWidget {
  final String userId;

  const UserDetailsPage({super.key, required this.userId});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  bool isLoading = true;
  bool hasError = false;
  late Map<String, dynamic> userDetails;
  bool isShakeSOSActive = false; // State for Shake SOS
  double shakeThreshold = 20.0; // Threshold to detect shake
  late StreamSubscription accelerometerSubscription;
  bool isSOSInProgress = false; // To prevent multiple SOS triggers

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    listenToShakeEvents();
  }

  @override
  void dispose() {
    accelerometerSubscription.cancel();
    super.dispose();
  }

  Future<void> fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('username') ?? 'Guest';

    final url = 'http://192.168.93.176:5000/api/personalinfo/$user';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          userDetails = json.decode(response.body);
          isLoading = false;
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

  void listenToShakeEvents() {
    accelerometerSubscription = accelerometerEvents.listen((event) {
      double gX = event.x / 9.8;
      double gY = event.y / 9.8;
      double gZ = event.z / 9.8;

      double gForce = gX * gX + gY * gY + gZ * gZ;

      if (gForce > shakeThreshold && isShakeSOSActive && !isSOSInProgress) {
        isSOSInProgress = true;
        sendSOS();
        Future.delayed(Duration(seconds: 5), () {
          isSOSInProgress = false; // Reset after 5 seconds
        });
      }
    });
  }

  Future<void> sendSOS() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SosActiveScreen()),
    );
    print("SOS Triggered!");
    // Add your API call or SOS logic here
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  String safeString(dynamic value) {
    if (value == null) return 'N/A';
    if (value is List) return value.join(', ');
    if (value is Map) return jsonEncode(value);
    return value.toString();
  }

  String formatEmergencyContact(dynamic contacts) {
    if (contacts is List && contacts.isNotEmpty) {
      return contacts.map((contact) {
        return '${contact['name']} - ${contact['phone']}';
      }).join('\n');
    }
    return 'No emergency contacts added';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? const Center(
                    child: Text('Error fetching data. Please try again later.',
                        style: TextStyle(fontSize: 16, color: Colors.red)))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Personal Information'),
                        _buildUserDetailCard(
                            'Name', safeString(userDetails['name'])),
                        _buildUserDetailCard(
                            'Mobile No', safeString(userDetails['mobileNo'])),
                        _buildUserDetailCard(
                            'Gender', safeString(userDetails['gender'])),
                        _buildUserDetailCard(
                            'State', safeString(userDetails['selectedState'])),
                        _buildUserDetailCard(
                            'Pincode', safeString(userDetails['pinCode'])),
                        _buildUserDetailCard(
                            'Address', safeString(userDetails['address'])),
                        _buildUserDetailCard(
                            'Aadhar No', safeString(userDetails['aadharNo'])),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Emergency Contacts'),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: Colors.white,
                            shadowColor: Colors.black.withOpacity(0.3),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Text(
                                formatEmergencyContact(
                                    userDetails['emergencyContacts']),
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[700]),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildSectionTitle('Shake SOS'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Enable Shake SOS",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple),
                            ),
                            Switch(
                              value: isShakeSOSActive,
                              onChanged: (value) {
                                setState(() {
                                  isShakeSOSActive = value;
                                });
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildUserDetailCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
