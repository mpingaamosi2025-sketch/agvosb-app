import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/alarm.dart';
import '../models/event.dart';

class StorageService {
  static const _eventsKey = 'agvosb.events';
  static const _alarmsKey = 'agvosb.alarms';
  static const _settingsKey = 'agvosb.settings';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  Future<List<CalendarEvent>> loadEvents() async {
    final values = (await _preferences).getStringList(_eventsKey) ?? [];
    return values
        .map((value) => CalendarEvent.fromJson(jsonDecode(value) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveEvents(List<CalendarEvent> events) async {
    final preferences = await _preferences;
    await preferences.setStringList(
      _eventsKey,
      events.map((event) => jsonEncode(event.toJson())).toList(),
    );
  }

  Future<List<AlarmItem>> loadAlarms() async {
    final values = (await _preferences).getStringList(_alarmsKey) ?? [];
    return values
        .map((value) => AlarmItem.fromJson(jsonDecode(value) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAlarms(List<AlarmItem> alarms) async {
    final preferences = await _preferences;
    await preferences.setStringList(
      _alarmsKey,
      alarms.map((alarm) => jsonEncode(alarm.toJson())).toList(),
    );
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final value = (await _preferences).getString(_settingsKey);
    return value == null ? {} : jsonDecode(value) as Map<String, dynamic>;
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await (await _preferences).setString(_settingsKey, jsonEncode(settings));
  }
}