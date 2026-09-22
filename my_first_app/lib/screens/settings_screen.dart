import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.isDarkMode, required this.firstDayOfWeek, required this.eventRemindersEnabled, required this.alarmNotificationsEnabled, required this.defaultSnooze, required this.defaultSound, required this.onDarkModeChanged, required this.onFirstDayChanged, required this.onEventRemindersChanged, required this.onAlarmNotificationsChanged, required this.onDefaultSnoozeChanged, required this.onDefaultSoundChanged});

  final bool isDarkMode;
  final int firstDayOfWeek;
  final bool eventRemindersEnabled;
  final bool alarmNotificationsEnabled;
  final int defaultSnooze;
  final String defaultSound;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<int> onFirstDayChanged;
  final ValueChanged<bool> onEventRemindersChanged;
  final ValueChanged<bool> onAlarmNotificationsChanged;
  final ValueChanged<int> onDefaultSnoozeChanged;
  final ValueChanged<String> onDefaultSoundChanged;

  Future<void> _chooseDay(BuildContext context) async {
    final selected = await showDialog<int>(context: context, builder: (context) => SimpleDialog(title: const Text('First day of week'), children: [SimpleDialogOption(onPressed: () => Navigator.pop(context, DateTime.sunday), child: const Text('Sunday')), SimpleDialogOption(onPressed: () => Navigator.pop(context, DateTime.monday), child: const Text('Monday'))]));
    if (selected != null) onFirstDayChanged(selected);
  }

  Future<void> _chooseSnooze(BuildContext context) async {
    final selected = await showDialog<int>(context: context, builder: (context) => SimpleDialog(title: const Text('Default snooze duration'), children: [5, 10, 15].map((value) => SimpleDialogOption(onPressed: () => Navigator.pop(context, value), child: Text('$value minutes'))).toList()));
    if (selected != null) onDefaultSnoozeChanged(selected);
  }

  Future<void> _chooseSound(BuildContext context) async {
    final selected = await showDialog<String>(context: context, builder: (context) => SimpleDialog(title: const Text('Default alarm sound'), children: ['Default', 'Alarm Sound 1', 'Alarm Sound 2', 'Alarm Sound 3'].map((value) => SimpleDialogOption(onPressed: () => Navigator.pop(context, value), child: Text(value))).toList()));
    if (selected != null) onDefaultSoundChanged(selected);
  }

  void _about(BuildContext context) => showAboutDialog(context: context, applicationName: 'AgVosb', applicationVersion: '1.0.0', applicationIcon: Image.asset('assets/image/agvosb_logo.png', width: 48, height: 48));

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Settings')), body: ListView(padding: const EdgeInsets.fromLTRB(16, 20, 16, 32), children: [
      _Section(title: 'Appearance', children: [SwitchListTile.adaptive(value: isDarkMode, onChanged: onDarkModeChanged, title: const Text('Dark Mode'), subtitle: const Text('Use a darker theme across AgVosb'), contentPadding: EdgeInsets.zero)]),
      const SizedBox(height: 18),
      _Section(title: 'Calendar', children: [ListTile(contentPadding: EdgeInsets.zero, title: const Text('First day of week'), subtitle: Text(firstDayOfWeek == DateTime.sunday ? 'Sunday' : 'Monday'), trailing: const Icon(Icons.chevron_right), onTap: () => _chooseDay(context))]),
      const SizedBox(height: 18),
      _Section(title: 'Notifications', children: [SwitchListTile.adaptive(value: eventRemindersEnabled, onChanged: onEventRemindersChanged, title: const Text('Event reminders'), contentPadding: EdgeInsets.zero), SwitchListTile.adaptive(value: alarmNotificationsEnabled, onChanged: onAlarmNotificationsChanged, title: const Text('Alarm notifications'), contentPadding: EdgeInsets.zero)]),
      const SizedBox(height: 18),
      _Section(title: 'Alarm', children: [ListTile(contentPadding: EdgeInsets.zero, title: const Text('Default snooze duration'), subtitle: Text('$defaultSnooze minutes'), trailing: const Icon(Icons.chevron_right), onTap: () => _chooseSnooze(context)), ListTile(contentPadding: EdgeInsets.zero, title: const Text('Default alarm sound'), subtitle: Text(defaultSound), trailing: const Icon(Icons.chevron_right), onTap: () => _chooseSound(context))]),
      const SizedBox(height: 18),
      _Section(title: 'About', children: [ListTile(contentPadding: EdgeInsets.zero, leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/image/agvosb_logo.png', width: 48, height: 48)), title: const Text('AgVosb'), subtitle: const Text('Version 1.0.0'), trailing: const Icon(Icons.chevron_right), onTap: () => _about(context))]),
    ]));
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary))), Material(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Column(children: children))) ]);
}
