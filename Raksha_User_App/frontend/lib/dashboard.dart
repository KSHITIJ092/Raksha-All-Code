import 'package:RAKSHA/camera.dart';
import 'package:RAKSHA/profile.dart';
import 'package:flutter/material.dart';
import 'package:RAKSHA/home.dart';
import 'package:RAKSHA/emergency%20services/emergency.dart'; // Import EmergencyScreen
import 'package:RAKSHA/emergency%20services/safety.dart'; // Import SafetyScreen
import 'package:RAKSHA/emergency%20services/emergency_numbers.dart'; // Import EmergencyNumbersScreen

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Roboto',
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDashboardSection(
                context,
                'Emergency Services',
                Icons.local_hospital,
                Colors.red,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EmergencyScreen()),
                  );
                },
              ),
              _buildDashboardSection(
                context,
                'Safety Guide',
                Icons.security,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SafetyScreen()),
                  );
                },
              ),
              _buildDashboardSection(
                context,
                'Emergency Numbers',
                Icons.phone,
                Colors.green,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EmergencyNumbersScreen()),
                  );
                },
              ),
              _buildDashboardSection(
                context,
                'Locate yourself',
                Icons.location_on,
                const Color.fromARGB(255, 193, 114, 175),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  CameraApp()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserDetailsPage(userId: '',)),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Personal Info',
          ),
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildDashboardSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
