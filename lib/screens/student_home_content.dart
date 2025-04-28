import 'package:flutter/material.dart';
import 'package:seat_sense_flutter/models/event_model.dart';
import 'package:seat_sense_flutter/screens/mark_attendance_screen.dart';
import 'package:seat_sense_flutter/screens/occupancy_screen.dart';
import 'package:seat_sense_flutter/services/event_service.dart';
import 'package:seat_sense_flutter/widgets/image_button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class StudentHomeContent extends StatefulWidget {
  const StudentHomeContent({super.key});

  @override
  State<StudentHomeContent> createState() => _StudentHomeContentState();
}

class _StudentHomeContentState extends State<StudentHomeContent> {
  final EventService _eventService = EventService();
  List<Event> _events = [];
  String? _selectedEventId;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final eventList = await _eventService.fetchEvents(context);
    setState(() {
      _events = eventList.map((e) => Event.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
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

          const SizedBox(height: 16),
          Divider(),
          const SizedBox(height: 12),

          ShadSelect<String>(
            placeholder: const Text('Select an Event'),
            minWidth: double.infinity,
            options:
                _events
                    .map(
                      (event) => ShadOption(
                        value: event.id,
                        child: Text('${event.name} (${event.date})'),
                      ),
                    )
                    .toList(),
            selectedOptionBuilder: (context, value) {
              final selected = _events.firstWhere((e) => e.id == value);
              return Text('${selected.name} (${selected.date})');
            },
            onChanged: (value) {
              setState(() {
                _selectedEventId = value;
              });
            },
          ),
          ShadButton(
            width: double.infinity,
            onPressed: () {
              if (_selectedEventId == null) {
                ShadToaster.of(
                  context,
                ).show(ShadToast(title: const Text('Please select an event')));
              } else {
                // Navigate to the Mark Attendance screen with the selected event ID
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            MarkAttendanceScreen(eventId: _selectedEventId!),
                  ),
                );
              }
            },
            child: const Text('Mark Attendance'),
          ),
        ],
      ),
    );
  }
}
