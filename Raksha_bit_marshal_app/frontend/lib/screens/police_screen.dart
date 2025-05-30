import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PoliceScreen extends StatefulWidget {
  const PoliceScreen({super.key});

  @override
  _PoliceScreenState createState() => _PoliceScreenState();
}

class _PoliceScreenState extends State<PoliceScreen> {
  late IO.Socket socket;
  List<Map<String, dynamic>> alerts = [];
  Set<int> visibleMaps = {}; // Tracks which alerts have their maps visible

  @override
  void initState() {
    super.initState();
    setupSocketConnection();
  }

  void setupSocketConnection() {
    socket = IO.io(
      'http://192.168.80.176:3000', // Replace with your server URL
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) => print('Connected to the server'));

    socket.onConnectError((error) => print('Connection error: $error'));

    socket.onDisconnect((_) => print('Disconnected from server'));

    socket.on('alert-userDetails', (data) {
      print('Received user details: $data');
      setState(() {
        alerts.add({
          'username': data['username'] ?? 'N/A',
          'latitude': data['latitude'] ?? 0.0,
          'longitude': data['longitude'] ?? 0.0,
          'name': data['details']['name'] ?? 'N/A',
          'mobileNo': data['details']['mobileNo'] ?? 'N/A',
          'gender': data['details']['gender'] ?? 'N/A',
          'createdAt': data['details']['createdAt'] ?? 'N/A',
          'status': 'Pending', // Default status
        });
      });

      /// Triggered when a new alert is received from the server
    });
  }

  void updateStatus(int index, String newStatus) {
    setState(() {
      alerts[index]['status'] = newStatus;
    });
  }

  void updateToAttended(int index) {
    updateStatus(index, 'Attended');
    // Notify server about the status update to Attended
    socket.emit('update-status', {
      'username': alerts[index]['username'],
      'status': 'Attended',
    });
  }

  void updateToClosed(int index) {
    updateStatus(index, 'Closed');
    // Notify server about the status update to Closed
    socket.emit('update-status', {
      'username': alerts[index]['username'],
      'status': 'Closed',
    });
  }

  void toggleMapVisibility(int index) {
    setState(() {
      if (visibleMaps.contains(index)) {
        visibleMaps.remove(index); // Hide map if already visible
      } else {
        visibleMaps.add(index); // Show map for the clicked alert
      }
    });
  }

  void update(int index) {
    // Determine the current status of the alert
    String currentStatus = alerts[index]['status'];

    String newStatus;

    // Determine the next status in the sequence
    if (currentStatus == 'Pending') {
      newStatus = 'Attended'; // First step: Update to "Attended"
    } else if (currentStatus == 'Attended') {
      newStatus = 'Closed'; // Second step: Update to "Closed"
    } else {
      return; // No change if already resolved
    }

    // Send the updated status to the server
    socket.emit('update-status', {
      'username': alerts[index]['username'],
      'status': newStatus,
    });

    // Optionally update the local state
    updateStatus(index, newStatus);
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Police Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Username: ${alert['username']}',
                      style: const TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Name: ${alert['name']}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'Mobile No: ${alert[' mobileNo']}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'Gender: ${alert['gender']}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'Reported At: ${alert['createdAt']}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'Status: ${alert['status']}',
                      style: const TextStyle(
                          fontSize: 16.0, color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (alert['status'] == 'Pending')
                          ElevatedButton(
                            onPressed: () => updateToAttended(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text('Mark Attended'),
                          ),
                        if (alert['status'] == 'Attended')
                          ElevatedButton(
                            onPressed: () => updateToClosed(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text('Mark Closed'),
                          ),
                        const SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () => toggleMapVisibility(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            visibleMaps.contains(index)
                                ? 'Hide Location'
                                : 'Show Location',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => update(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            alerts[index]['status'] == 'Closed'
                                ? 'Resolved' // Display Resolved if it's the final status
                                : 'Update Status',
                          ),
                        ),
                      ],
                    ),
                    if (visibleMaps
                        .contains(index)) // Show map if index is in visibleMaps
                      SizedBox(
                        height: 200,
                        child: FlutterMap(
                          options: MapOptions(
                            center:
                                LatLng(alert['latitude'], alert['longitude']),
                            zoom: 15.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(
                                      alert['latitude'], alert['longitude']),
                                  builder: (context) => const Icon(
                                    Icons.location_pin,
                                    size: 40.0,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
