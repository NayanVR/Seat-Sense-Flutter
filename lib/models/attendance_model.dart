class AttendanceRecord {
  final String firstName;
  final String lastName;
  final String email;
  final String userId;
  final String eventId;
  final double latitude;
  final double longitude;
  final DateTime time;

  AttendanceRecord({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userId,
    required this.eventId,
    required this.latitude,
    required this.longitude,
    required this.time,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      userId: json['user_id'],
      eventId: json['event_id'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      time: DateTime.parse(json['time']),
    );
  }
}
