class Event {
  final String id;
  final String name;
  final String date;
  final String startTime;
  final String endTime;
  final String? description;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['event_id'],
      name: json['name'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      if (description != null) 'description': description,
    };
  }
}
