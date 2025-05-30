import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Self-Defense Techniques',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: List.generate(_techniques.length, (index) {
                final technique = _techniques[index];
                return _buildTechniqueCard(
                  context,
                  title: technique['title']!,
                  description: technique['description']!,
                  icon: technique['icon']!,
                  color: technique['color']!,
                  videoLink: technique['videoLink']!,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTechniqueCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String videoLink,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          // Open a dialog with technique details
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: color,
                      child: Icon(icon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 10),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                content: SizedBox(
                  height: 260, // Reduced height for smaller dialog
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(description, style: const TextStyle(fontSize: 19)),
                      const SizedBox(height: 15),
                      const Text("Watch the video for better learning:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _launchURL(videoLink),
                        child: const Text(
                          "Watch on YouTube",
                          style: TextStyle(fontSize: 15, color: Colors.blueAccent, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
        },
        child: Card(
          elevation: 15, // Slightly stronger elevation for more depth
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.4), color.withOpacity(0.8)], // Less subtle gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25.0),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4), // Stronger shadow
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: const Offset(0, 8), // Stronger shadow effect
                ),
                BoxShadow(
                  color: color.withOpacity(0.2), // Lighter shadow for subtle depth
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: Colors.white,
                  child: Icon(icon, color: color, size: 38),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 15, color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to launch YouTube URL
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static const List<Map<String, dynamic>> _techniques = [
    {
      'title': 'Choke Hold Escape',
      'description': 'When trapped in a choke hold, use your hands to break the attacker’s grip. Utilize your legs to push and create space.',
      'icon': Icons.access_alarm,
      'color': Colors.deepPurpleAccent,
      'videoLink': 'https://youtube.com/shorts/8MpFS5wvSAM?feature=shared',
    },
    {
      'title': 'Bear Hug Escape',
      'description': 'To break free from a bear hug, drop your weight and use your head to strike the attacker’s face while bringing your elbows down.',
      'icon': Icons.handshake,
      'color': Colors.indigo,
      'videoLink': 'https://youtube.com/shorts/1iWpe6M--lk?feature=shared',
    },
    {
      'title': 'Elbow Strike to Jaw',
      'description': 'Deliver a strong elbow strike to the attacker’s jaw. This can cause disorientation and create an opportunity for escape.',
      'icon': Icons.pan_tool,
      'color': Colors.redAccent,
      'videoLink': 'https://youtu.be/xjUbPBGBf1Y?feature=shared',
    },
    {
      'title': 'Knee to Groin',
      'description': 'A knee to the groin is a powerful move that can instantly incapacitate your attacker, creating a chance to flee or follow up with another move.',
      'icon': Icons.directions_run,
      'color': Colors.orangeAccent,
      'videoLink': 'https://youtube.com/shorts/DkYNU3tNUfE?feature=shared',
    },
    {
      'title': 'Roundhouse Kick',
      'description': 'A roundhouse kick to the side of the head or ribs can disable an attacker quickly. Aim for the head for maximum effect.',
      'icon': Icons.sports_kabaddi,
      'color': Colors.blueAccent,
      'videoLink': 'https://youtu.be/e64AtWekQVo?feature=shared',
    },
    {
      'title': 'Wrist Lock',
      'description': 'To disarm an attacker, use a wrist lock by twisting the arm and applying pressure to force them into submission.',
      'icon': Icons.security,
      'color': Colors.greenAccent,
      'videoLink': 'https://youtube.com/shorts/HkdxoZJtebg?feature=shared',
    },
    {
      'title': 'Hammer Fist Strike',
      'description': 'The hammer fist is a powerful strike delivered with the bottom of the fist. Target the nose, chin, or collarbone for maximum damage.',
      'icon': Icons.touch_app,
      'color': Colors.cyanAccent,
      'videoLink': 'https://youtube.com/shorts/sLeaY1-nzmA?feature=shared',
    },
    {
      'title': 'Palm Heel Strike',
      'description': 'Use the heel of your palm to strike upward into the attacker’s nose or chin. This strike is effective at creating distance.',
      'icon': Icons.fingerprint,
      'color': Colors.amber,
      'videoLink': 'https://youtube.com/shorts/XJlxv_GHiFU?feature=shared',
    },
    {
      'title': 'Leg Sweep',
      'description': 'A leg sweep involves quickly sweeping the attacker’s legs from under them. This will cause them to lose balance and fall to the ground.',
      'icon': Icons.filter_tilt_shift,
      'color': Colors.pinkAccent,
      'videoLink': 'https://youtube.com/shorts/BuMZKGa9PCg?feature=shared',
    },
    {
      'title': 'Headbutt',
      'description': 'A headbutt to the attackers face or chest can incapacitate them immediately. This move is fast and powerful.',
      'icon': Icons.headset_mic,
      'color': Colors.red,
      'videoLink': 'https://youtu.be/icuDelamSGc?feature=shared',
    },
    {
      'title': 'Armbar Submission',
      'description': 'An armbar submission locks the opponent’s arm, hyperextending the elbow joint. This can render them immobile and give you control.',
      'icon': Icons.sports_mma,
      'color': Colors.purpleAccent,
      'videoLink': 'https://youtube.com/shorts/yPHEGRnRem0?feature=shared ',
    },
  ];
}
