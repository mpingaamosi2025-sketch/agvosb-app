class AlarmItem {
  const AlarmItem({
    required this.id,
    required this.time,
    required this.name,
    required this.repeat,
    required this.days,
    required this.sound,
    required this.snoozeMinutes,
    required this.enabled,
  });

  final String id;
  final DateTime time;
  final String name;
  final String repeat;
  final List<int> days;
  final String sound;
  final int snoozeMinutes;
  final bool enabled;

  AlarmItem copyWith({
    DateTime? time,
    String? name,
    String? repeat,
    List<int>? days,
    String? sound,
    int? snoozeMinutes,
    bool? enabled,
  }) {
    return AlarmItem(
      id: id,
      time: time ?? this.time,
      name: name ?? this.name,
      repeat: repeat ?? this.repeat,
      days: days ?? this.days,
      sound: sound ?? this.sound,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': time.toIso8601String(),
        'name': name,
        'repeat': repeat,
        'days': days,
        'sound': sound,
        'snoozeMinutes': snoozeMinutes,
        'enabled': enabled,
      };

  factory AlarmItem.fromJson(Map<String, dynamic> json) {
    return AlarmItem(
      id: json['id'] as String,
      time: DateTime.parse(json['time'] as String),
      name: json['name'] as String,
      repeat: json['repeat'] as String? ?? 'Once',
      days: (json['days'] as List<dynamic>? ?? []).cast<int>(),
      sound: json['sound'] as String? ?? 'Default',
      snoozeMinutes: json['snoozeMinutes'] as int? ?? 5,
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}