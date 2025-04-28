import 'package:flutter/material.dart';
import 'package:seat_sense_flutter/screens/occupancy_screen.dart';
import 'package:seat_sense_flutter/screens/view_attendance_screen.dart';
import 'package:seat_sense_flutter/screens/view_events_screen.dart';
import 'package:seat_sense_flutter/widgets/image_button.dart';

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
          ImageButton(
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
          ImageButton(
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
          ImageButton(
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
}
