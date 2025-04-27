import 'package:flutter/material.dart';
import 'package:seat_sense_flutter/models/event_model.dart';
import 'package:seat_sense_flutter/services/attendance_service.dart';
import 'package:seat_sense_flutter/services/event_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ViewAttendanceScreen extends StatefulWidget {
  const ViewAttendanceScreen({super.key});

  @override
  State<ViewAttendanceScreen> createState() => _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends State<ViewAttendanceScreen> {
  final EventService _eventService = EventService();
  final AttendanceService _attendanceService = AttendanceService();
  final TextEditingController _enrollmentController = TextEditingController();

  List<Event> _events = [];
  Event? _selectedEvent;
  List<Map<String, dynamic>> _attendanceRecords = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final events = await _eventService.fetchEvents(context);
    setState(() {
      _events = events.map((e) => Event.fromJson(e)).toList();
    });
  }

  Future<void> _fetchAttendance() async {
    if (_selectedEvent == null) return;
    setState(() {
      _loading = true;
    });
    final records = await _attendanceService.fetchAttendanceByEvent(
      context: context,
      eventId: _selectedEvent!.id,
    );
    setState(() {
      _attendanceRecords = records;
      _loading = false;
    });
  }

  Future<void> _deleteAttendance(String attendanceId) async {
    final success = await _attendanceService.deleteAttendance(
      context: context,
      attendanceId: attendanceId,
    );
    if (success) {
      ShadToaster.of(context).show(
        const ShadToast(description: Text('Attendance deleted successfully.')),
      );
      _fetchAttendance();
    }
  }

  void _showManualAttendanceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff2563eb),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Add Enrollment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Text(
                      'Enrollment Number',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ShadInput(
                      controller: _enrollmentController,
                      placeholder: const Text('Enter enrollment number'),
                      keyboardType: TextInputType.text,
                      autofocus: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton.outline(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ShadButton(
                        onPressed: () async {
                          final enrollment = _enrollmentController.text.trim();
                          if (enrollment.isNotEmpty && _selectedEvent != null) {
                            final email = '$enrollment@gsfcuniversity.ac.in';
                            final success = await _attendanceService
                                .manualMarkAttendance(
                                  context: context,
                                  email: email,
                                  eventId: _selectedEvent!.id,
                                );
                            if (success) {
                              ShadToaster.of(context).show(
                                const ShadToast(
                                  description: Text(
                                    'Attendance marked successfully.',
                                  ),
                                ),
                              );
                              Navigator.of(context).pop();
                              _enrollmentController.clear();
                              _fetchAttendance();
                            }
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _getEventOptions(ShadThemeData theme) {
    return _events.map((event) {
      return ShadOption(value: event.id, child: Text(event.name));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ShadSelect<String>(
                placeholder: const Text('Select an event'),
                options: _getEventOptions(theme),
                selectedOptionBuilder: (context, value) {
                  final eventName =
                      _events.firstWhere((e) => e.id == value).name;
                  return Text(eventName);
                },
                onChanged: (value) {
                  setState(() {
                    _selectedEvent = _events.firstWhere((e) => e.id == value);
                  });
                  _fetchAttendance();
                },
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_attendanceRecords.isEmpty)
              const Text('No attendance records found.')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _attendanceRecords.length,
                  itemBuilder: (context, index) {
                    final record = _attendanceRecords[index];
                    final formattedTime =
                        record['time'] != null
                            ? DateFormat.Hms().format(
                              DateTime.parse(record['time']).toLocal(),
                            )
                            : '';
                    final enrollmentNumber =
                        record['email']?.split('@').first ?? '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: Key(
                          record['id'] ?? record['email'] ?? index.toString(),
                        ),
                        direction: DismissDirection.endToStart,
                        background: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Same rounding as the container
                          child: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Color(0xffee2241),
                            child: const Icon(
                              LucideIcons.trash,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text(
                                    'Are you sure you want to delete this attendance?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                          );
                          return confirm ?? false;
                        },
                        onDismissed: (direction) {
                          if (record['id'] != null) {
                            _deleteAttendance(record['id']);
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // rounded border for container
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${record['first_name']} ${record['last_name']}',
                                  style: theme.textTheme.small,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Enrollment: $enrollmentNumber',
                                  style: theme.textTheme.small,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Time: $formattedTime',
                                  style: theme.textTheme.small,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton:
          _selectedEvent != null
              ? FloatingActionButton(
                backgroundColor: const Color(0xff2563eb),
                onPressed: _showManualAttendanceDialog,
                child: const Icon(Icons.add, color: Colors.white),
              )
              : null,
    );
  }
}
