import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class EmergencyNumbersScreen extends StatelessWidget {
  const EmergencyNumbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emergencyNumbers = [
      {'name': 'Women’s Helpline', 'number': '1091'},
      {'name': 'Police Control Room', 'number': '100'},
      {'name': 'Fire Brigade', 'number': '101'},
      {'name': 'Ambulance', 'number': '108'},
      {'name': 'Child Helpline', 'number': '1098'},
      {'name': 'Disaster Management', 'number': '1070'},
      {'name': 'Railway Helpline', 'number': '139'},
      {'name': 'Cyber Crime', 'number': '1930'},
      {'name': 'Senior Citizens Helpline', 'number': '1291'},
      {'name': 'Mumbai Traffic Police Helpline', 'number': '8454999999'},
      {'name': 'Thane Police Helpline', 'number': '02225442434'},
      {'name': 'Women’s Helpline Maharashtra', 'number': '181'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.pink[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: emergencyNumbers.length,
          itemBuilder: (context, index) {
            final contact = emergencyNumbers[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              shadowColor: Colors.grey.withOpacity(0.2),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.pinkAccent,
                  child: Icon(
                    Icons.phone,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                title: Text(
                  contact['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Contact: ${contact['number']}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  ),
                  onPressed: () async {
                    await _makePhoneCall(context, contact['number']!);
                  },
                  child: const Text(
                    'Call',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(BuildContext context, String number) async {
    final PermissionStatus permissionStatus = await Permission.phone.request();

    if (permissionStatus.isGranted) {
      try {
        const platform = MethodChannel('com.example.calls'); // Ensure it matches your Kotlin implementation
        await platform.invokeMethod('makeCall', {'number': number});
      } catch (e) {
        print('Error occurred while trying to call $number: $e');
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
}