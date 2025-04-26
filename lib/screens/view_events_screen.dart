import 'package:flutter/material.dart';
import 'package:seat_sense_flutter/models/event_model.dart';
import 'package:seat_sense_flutter/services/event_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';


class ViewEventsScreen extends StatefulWidget {
  const ViewEventsScreen({super.key});


  @override
  State<ViewEventsScreen> createState() => _ViewEventsScreenState();
}


class _ViewEventsScreenState extends State<ViewEventsScreen> {
  final EventService _eventService = EventService();
  List<Event> _events = [];
  bool _loading = true;


  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }


  Future<void> _fetchEvents() async {
    final rawEvents = await _eventService.fetchEvents(context);
    final events = rawEvents.map((e) => Event.fromJson(e)).toList();


    events.sort((a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)));


    setState(() {
      _events = events;
      _loading = false;
    });
  }


  Future<void> _showViewEventDialog(String eventId) async {
    final event = await _eventService.viewEvent(context, eventId);
    if (event == null) return;


    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDialogTitle(event['name'] ?? 'Event Details'),
                const SizedBox(height: 16),
                _buildViewDetailItem(Icons.calendar_month, 'Date', event['date']),
                _buildViewDetailItem(Icons.schedule, 'Start Time', event['start_time']),
                _buildViewDetailItem(Icons.timelapse, 'End Time', event['end_time']),
                _buildViewDetailItem(Icons.location_on, 'Location', event['location']),
                const SizedBox(height: 16),
                const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(event['description'] ?? '-'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ShadButton(
                      child: const Text('Close'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _showAddOrEditEventDialog({Event? event}) async {
    final isEditing = event != null;
    final nameController = TextEditingController(text: event?.name ?? '');
    final descriptionController = TextEditingController(text: event?.description ?? '');
    final locationController = TextEditingController(text: event?.location ?? '');
    final dateController = TextEditingController(text: event?.date ?? '');
    final startTimeController = TextEditingController(text: event?.startTime ?? '');
    final endTimeController = TextEditingController(text: event?.endTime ?? '');
    final formKey = GlobalKey<FormState>();


    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: double.infinity),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDialogTitle(isEditing ? 'Edit Event' : 'Add New Event'),
                    const SizedBox(height: 16),
                    _eventFormFields(
                      nameController,
                      descriptionController,
                      locationController,
                      dateController,
                      startTimeController,
                      endTimeController,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ShadButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        ShadButton(
                          child: Text(isEditing ? 'Update' : 'Add'),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              if (!_validateTimes(startTimeController, endTimeController)) return;
                              final data = {
                                if (isEditing) 'event_id': event.id,
                                'name': nameController.text.trim(),
                                'description': descriptionController.text.trim(),
                                'location': locationController.text.trim(),
                                'date': dateController.text.trim(),
                                'start_time': startTimeController.text.trim(),
                                'end_time': endTimeController.text.trim(),
                              };
                              final success = isEditing
                                  ? await _eventService.editEvent(context, data)
                                  : await _eventService.createEvent(context, data);
                              if (success) {
                                Navigator.pop(context);
                                await _fetchEvents();
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _confirmAndDeleteEvent(String eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          ShadButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ShadButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );


    if (confirmed == true) {
      final success = await _eventService.deleteEvent(context, eventId);
      if (success) {
        await _fetchEvents(); // Refresh after successful delete
      }
    }
  }


  Widget _eventFormFields(
    TextEditingController nameController,
    TextEditingController descriptionController,
    TextEditingController locationController,
    TextEditingController dateController,
    TextEditingController startTimeController,
    TextEditingController endTimeController,
  ) {
    final fields = [
      ShadInputFormField(
        id: 'name',
        label: const Text('Name'),
        placeholder: const Text('Enter event name'),
        validator: (v) => v.length < 2 ? 'Name must be at least 2 characters.' : null,
        controller: nameController,
      ),
      ShadInputFormField(
        id: 'description',
        label: const Text('Description'),
        placeholder: const Text('Enter event description'),
        controller: descriptionController,
      ),
      ShadInputFormField(
        id: 'location',
        label: const Text('Location'),
        placeholder: const Text('Enter event location'),
        validator: (v) => v.isEmpty ? 'Location is required.' : null,
        controller: locationController,
      ),
      ShadInputFormField(
        id: 'date',
        label: const Text('Date (YYYY-MM-DD)'),
        placeholder: const Text('Pick event date'),
        readOnly: true,
        controller: dateController,
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (picked != null) {
            dateController.text = picked.toIso8601String().split('T')[0];
          }
        },
      ),
      ShadInputFormField(
        id: 'start_time',
        label: const Text('Start Time (HH:mm)'),
        placeholder: const Text('Pick start time'),
        readOnly: true,
        controller: startTimeController,
        onPressed: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            startTimeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          }
        },
      ),
      ShadInputFormField(
        id: 'end_time',
        label: const Text('End Time (HH:mm)'),
        placeholder: const Text('Pick end time'),
        readOnly: true,
        controller: endTimeController,
        onPressed: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            endTimeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          }
        },
      ),
    ];


    return Column(
      children: List.generate(fields.length * 2 - 1, (index) {
        if (index.isEven) {
          return fields[index ~/ 2];
        } else {
          return const SizedBox(height: 16); // Gap between fields
        }
      }),
    );
  }


  bool _validateTimes(TextEditingController start, TextEditingController end) {
    final startTime = DateTime.parse('2024-01-01 ${start.text}');
    final endTime = DateTime.parse('2024-01-01 ${end.text}');
    if (startTime.isAfter(endTime) || startTime.isAtSameMomentAs(endTime)) {
      ShadToaster.of(context).show(
        const ShadToast(title: Text('Start time must be before End time')),
      );
      return false;
    }
    return true;
  }


  Widget _buildDialogTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xff2563eb),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }


  Widget _buildViewDetailItem(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xff2563eb)),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value ?? '-')),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final headings = ['Date', 'Name', 'Actions'];


    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ShadTable(
                columnCount: headings.length,
                rowCount: _events.length,
                columnSpanExtent: (index) {
                  if (index == 0) {
                    return const FixedTableSpanExtent(100); // Date
                  } else if (index == 1) {
                    return const FixedTableSpanExtent(150); // Name (give more width)
                  } else if (index == 2) {
                    return const FixedTableSpanExtent(176); // Actions
                  }
                  return null;
                },


                header: (context, column) {
                  final isLast = column == headings.length - 1;
                  return ShadTableCell.header(
                    alignment: isLast ? Alignment.center : null,
                    child: Text(headings[column]),
                  );
                },
                builder: (context, index) {
                  final event = _events[index.row];
                  return switch (index.column) {
                    0 => ShadTableCell(child: Text(event.date)),
                    1 => ShadTableCell(
                      child: Text(
                        event.name,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    2 => ShadTableCell(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.eye),
                            tooltip: 'View',
                            onPressed: () => _showViewEventDialog(event.id),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.pen),
                            tooltip: 'Edit',
                            onPressed: () => _showAddOrEditEventDialog(event: event),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.trash),
                            tooltip: 'Delete',
                            onPressed: () async {
                              await _confirmAndDeleteEvent(event.id);
                            },
                          ),
                        ],
                      ),
                    ),
                    _ => const ShadTableCell(child: SizedBox()),
                  };
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditEventDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}


