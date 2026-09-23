import 'package:flutter/material.dart';

import 'models/alarm.dart';
import 'models/event.dart';
import 'screens/add_alarm_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/alarm_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/music_screen.dart';
import 'screens/now_playing_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/stopwatch_screen.dart';
import 'screens/video_screen.dart';
import 'services/audio_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'widgets/mini_player.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = await StorageService().loadSettings();
  final initialDarkMode = settings['darkMode'] as bool? ?? false;
  final audio = await AudioService.initialize();

  runApp(AgVosbApp(initialDarkMode: initialDarkMode, audio: audio));
}

class AgVosbApp extends StatefulWidget {
  const AgVosbApp({super.key, this.initialDarkMode = false, required this.audio});
  final bool initialDarkMode;
  final AudioService audio;

  @override
  State<AgVosbApp> createState() => AgVosbAppState();
}

class AgVosbAppState extends State<AgVosbApp> {
  final StorageService storage = StorageService();
  final NotificationService notifications = NotificationService();
  late final AudioService audio = widget.audio;
  List<CalendarEvent> events = [];
  List<AlarmItem> alarms = [];
  bool isDarkMode;
  bool firstDaySunday = true;
  bool eventRemindersEnabled = true;
  bool alarmNotificationsEnabled = true;
  int defaultSnooze = 5;
  String defaultSound = 'Default';
  bool ready = false;
  bool showSplash = true;
  bool splashFinished = false;

  AgVosbAppState() : isDarkMode = false;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.initialDarkMode;
    _load();
  }

  Future<void> _load() async {
    try {
      events = await storage.loadEvents();
      alarms = await storage.loadAlarms();
      final settings = await storage.loadSettings();
      isDarkMode = settings['darkMode'] as bool? ?? false;
      firstDaySunday = (settings['firstDayOfWeek'] as int? ?? DateTime.sunday) == DateTime.sunday;
      eventRemindersEnabled = settings['eventReminders'] as bool? ?? true;
      alarmNotificationsEnabled = settings['alarmNotifications'] as bool? ?? true;
      defaultSnooze = settings['defaultSnooze'] as int? ?? 5;
      defaultSound = settings['defaultSound'] as String? ?? 'Default';
      await notifications.initialize();
    } catch (_) {}
    if (mounted) {
      setState(() {
        ready = true;
        if (splashFinished) showSplash = false;
      });
    }
  }

  void finishSplash() {
    if (!mounted) return;
    setState(() => showSplash = !ready);
  }

  Future<void> _saveSettings() => storage.saveSettings({
        'darkMode': isDarkMode,
        'firstDayOfWeek': firstDaySunday ? DateTime.sunday : DateTime.monday,
        'eventReminders': eventRemindersEnabled,
        'alarmNotifications': alarmNotificationsEnabled,
        'defaultSnooze': defaultSnooze,
        'defaultSound': defaultSound,
      });

  Future<void> saveEvent(CalendarEvent event) async {
    setState(() {
      final index = events.indexWhere((item) => item.id == event.id);
      if (index == -1) {
        events = [...events, event];
      } else {
        events[index] = event;
        events = [...events];
      }
    });
    await storage.saveEvents(events);
    await notifications.cancel(event.id.hashCode);
    if (eventRemindersEnabled) {
      await notifications.schedule(id: event.id.hashCode, title: event.title, body: event.description.isEmpty ? 'AgVosb event reminder' : event.description, date: event.startTime.subtract(Duration(minutes: event.reminder)));
    }
  }

  Future<void> deleteEvent(CalendarEvent event) async {
    setState(() => events = events.where((item) => item.id != event.id).toList());
    await storage.saveEvents(events);
    await notifications.cancel(event.id.hashCode);
  }

  Future<void> saveAlarm(AlarmItem alarm) async {
    setState(() {
      final index = alarms.indexWhere((item) => item.id == alarm.id);
      if (index == -1) {
        alarms = [...alarms, alarm];
      } else {
        alarms[index] = alarm;
        alarms = [...alarms];
      }
    });
    await storage.saveAlarms(alarms);
    await notifications.cancel(alarm.id.hashCode);
    if (alarm.enabled && alarmNotificationsEnabled) {
      await notifications.schedule(id: alarm.id.hashCode, title: alarm.name, body: 'AgVosb alarm', date: _nextAlarmTime(alarm));
    }
  }

  DateTime _nextAlarmTime(AlarmItem alarm) {
    final now = DateTime.now();
    var result = DateTime(now.year, now.month, now.day, alarm.time.hour, alarm.time.minute);
    if (result.isBefore(now)) result = result.add(const Duration(days: 1));
    return result;
  }

  Future<void> deleteAlarm(AlarmItem alarm) async {
    setState(() => alarms = alarms.where((item) => item.id != alarm.id).toList());
    await storage.saveAlarms(alarms);
    await notifications.cancel(alarm.id.hashCode);
  }

  void updateSetting(VoidCallback change) {
    setState(change);
    _saveSettings();
  }

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF087EA4), brightness: brightness);
    return ThemeData(colorScheme: scheme, useMaterial3: true, scaffoldBackgroundColor: brightness == Brightness.light ? const Color(0xFFF7FAFC) : const Color(0xFF10181D), inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgVosb',
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: showSplash ? SplashScreen(isDarkMode: isDarkMode, onFinished: finishSplash) : MainScreen(app: this),
    );
  }

  @override
  void dispose() {
    audio.dispose();
    super.dispose();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.app});
  final AgVosbAppState app;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  Future<void> _addEvent([DateTime? date]) async {
    final event = await Navigator.of(context).push<CalendarEvent>(MaterialPageRoute(builder: (_) => AddEventScreen(initialDate: date)));
    if (event != null) await widget.app.saveEvent(event);
  }

  Future<void> _editEvent(CalendarEvent event) async {
    final updated = await Navigator.of(context).push<CalendarEvent>(MaterialPageRoute(builder: (_) => AddEventScreen(event: event)));
    if (updated != null) await widget.app.saveEvent(updated);
  }

  Future<void> _addAlarm([AlarmItem? alarm]) async {
    final updated = await Navigator.of(context).push<AlarmItem>(MaterialPageRoute(builder: (_) => AddAlarmScreen(alarm: alarm)));
    if (updated != null) await widget.app.saveAlarm(updated);
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final screens = [
      HomeScreen(
        events: app.events,
        alarms: app.alarms,
        onOpen: (index) => setState(() => selectedIndex = index),
      ),
      CalendarScreen(
        firstDayOfWeek: app.firstDaySunday ? DateTime.sunday : DateTime.monday,
        events: app.events,
        onAddEvent: _addEvent,
        onEditEvent: _editEvent,
        onDeleteEvent: app.deleteEvent,
      ),
      AlarmScreen(
        alarms: app.alarms,
        onAdd: _addAlarm,
        onEdit: _addAlarm,
        onDelete: app.deleteAlarm,
        onToggle: (alarm, enabled) => app.saveAlarm(alarm.copyWith(enabled: enabled)),
      ),
      MusicScreen(
        audio: app.audio,
        onSongSelected: (song, songs) {
          widget.app.audio.playSong(song, songs: songs);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NowPlayingScreen(
                song: song,
                audio: app.audio,
              ),
            ),
          );
        },
      ),
      VideoScreen(),
      const StopwatchScreen(),
      SettingsScreen(
        isDarkMode: app.isDarkMode,
        firstDayOfWeek: app.firstDaySunday ? DateTime.sunday : DateTime.monday,
        eventRemindersEnabled: app.eventRemindersEnabled,
        alarmNotificationsEnabled: app.alarmNotificationsEnabled,
        defaultSnooze: app.defaultSnooze,
        defaultSound: app.defaultSound,
        onDarkModeChanged: (value) => app.updateSetting(() => app.isDarkMode = value),
        onFirstDayChanged: (value) => app.updateSetting(() => app.firstDaySunday = value == DateTime.sunday),
        onEventRemindersChanged: (value) => app.updateSetting(() => app.eventRemindersEnabled = value),
        onAlarmNotificationsChanged: (value) => app.updateSetting(() => app.alarmNotificationsEnabled = value),
        onDefaultSnoozeChanged: (value) => app.updateSetting(() => app.defaultSnooze = value),
        onDefaultSoundChanged: (value) => app.updateSetting(() => app.defaultSound = value),
      ),
    ];

    return AnimatedBuilder(
      animation: app.audio,
      builder: (context, _) {
        final currentSong = app.audio.currentSong;
        return Scaffold(
          body: IndexedStack(index: selectedIndex, children: screens),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentSong != null && selectedIndex != 3 && selectedIndex != 4)
                MiniPlayer(
                  song: currentSong,
                  isPlaying: app.audio.isPlaying,
                  position: app.audio.position,
                  duration: app.audio.duration,
                  onPrevious: app.audio.previous,
                  onNext: app.audio.next,
                  onPlayPause: app.audio.togglePlayPause,
                ),
          NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => setState(() => selectedIndex = index),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendar'),
              NavigationDestination(icon: Icon(Icons.alarm_outlined), selectedIcon: Icon(Icons.alarm), label: 'Alarm'),
              NavigationDestination(icon: Icon(Icons.music_note_outlined), selectedIcon: Icon(Icons.music_note), label: 'Music'),
              NavigationDestination(icon: Icon(Icons.videocam_outlined), selectedIcon: Icon(Icons.videocam), label: 'Video'),
              NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer), label: 'Timer'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
            ],
              ),
            ],
          ),
        );
      },
    );
  }
}
