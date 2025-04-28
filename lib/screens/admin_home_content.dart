import 'package:flutter/material.dart';
import 'package:seat_sense_flutter/screens/occupancy_screen.dart';
import 'package:seat_sense_flutter/screens/view_attendance_screen.dart';
import 'package:seat_sense_flutter/screens/view_events_screen.dart';

class AdminHomeContent extends StatelessWidget {
  const AdminHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // View Occupancy Image Card
          _buildImageCard(
            context: context,
            screenWidth: screenWidth,
            imagePath: 'lib/assets/audi_ghibli.png',
            title: 'View Occupancy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OccupancyScreen()),
              );
            },
          ),

          const SizedBox(height: 18),

          // View Attendance Image Card
          _buildImageCard(
            context: context,
            screenWidth: screenWidth,
            imagePath: 'lib/assets/audi_filled_ghibli.png',
            title: 'View Attendance',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewAttendanceScreen()),
              );
            },
          ),

          const SizedBox(height: 18),

          // View Events Image Card
          _buildImageCard(
            context: context,
            screenWidth: screenWidth,
            imagePath: 'lib/assets/events_ghibli_baal.png',
            title: 'View Events',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewEventsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard({
    required BuildContext context,
    required double screenWidth,
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                height: 220,
                width: screenWidth,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              height: 220,
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withAlpha(
                  (0.3 * 255).toInt(),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 6,
                    color: Colors.black,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
