import 'package:flutter/material.dart';

import '../models/alarm.dart';
import '../models/event.dart';
import '../widgets/app_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.events, required this.alarms, required this.onOpen});

  final List<CalendarEvent> events;
  final List<AlarmItem> alarms;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final upcomingEvents = events.where((event) => _sameDay(event.date, today)).length;
    final activeAlarms = alarms.where((alarm) => alarm.enabled).length;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/image/agvosb_logo.png', width: 54, height: 54)),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Good day', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Text('AgVosb', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              ]),
            ],
          ),
          const SizedBox(height: 28),
          Text('Your productivity space', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          SizedBox(
            height: 178,
            child: Row(children: [
              Expanded(child: AppCard(icon: Icons.calendar_month, title: 'Calendar', subtitle: '$upcomingEvents events today', onTap: () => onOpen(1))),
              const SizedBox(width: 12),
              Expanded(child: AppCard(icon: Icons.alarm, title: 'Alarm', subtitle: '$activeAlarms active', onTap: () => onOpen(2), color: theme.colorScheme.tertiary)),
            ]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 178,
            child: Row(
              children: [
                Expanded(child: AppCard(icon: Icons.music_note, title: 'Music', subtitle: 'Local playlists', onTap: () => onOpen(3), color: theme.colorScheme.primary)),
                const SizedBox(width: 12),
                Expanded(child: AppCard(icon: Icons.videocam, title: 'Video', subtitle: 'Watch locally', onTap: () => onOpen(4), color: theme.colorScheme.secondary)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(height: 150, child: AppCard(icon: Icons.timer, title: 'Stopwatch', subtitle: 'Track every second', onTap: () => onOpen(5), color: theme.colorScheme.secondary)),
          const SizedBox(height: 26),
          Card(
            child: ListTile(
              leading: const Icon(Icons.tips_and_updates_outlined),
              title: const Text('Make time work for you'),
              subtitle: const Text('Plan your day, set alarms, and stay focused.'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => onOpen(1),
            ),
          ),
        ],
      ),
    );
  }
}

bool _sameDay(DateTime first, DateTime second) => first.year == second.year && first.month == second.month && first.day == second.day;