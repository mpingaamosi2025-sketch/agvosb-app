class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.reminder,
    required this.repeat,
  });

  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final int reminder;
  final String repeat;

  CalendarEvent copyWith({
    String? title,
    String? description,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    int? reminder,
    String? repeat,
  }) {
    return CalendarEvent(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reminder: reminder ?? this.reminder,
      repeat: repeat ?? this.repeat,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'reminder': reminder,
        'repeat': repeat,
      };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      reminder: json['reminder'] as int? ?? 0,
      repeat: json['repeat'] as String? ?? 'Never',
    );
  }
}