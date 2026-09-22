import 'package:flutter/material.dart';

import '../models/alarm.dart';

class AddAlarmScreen extends StatefulWidget {
  const AddAlarmScreen({super.key, this.alarm});

  final AlarmItem? alarm;

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  late final TextEditingController nameController;
  late TimeOfDay time;
  late String repeat;
  late String sound;
  late int snooze;
  late List<int> days;

  @override
  void initState() {
    super.initState();
    final alarm = widget.alarm;
    nameController = TextEditingController(text: alarm?.name ?? 'Wake up');
    time = TimeOfDay.fromDateTime(alarm?.time ?? DateTime.now());
    repeat = alarm?.repeat ?? 'Once';
    sound = alarm?.sound ?? 'Default';
    snooze = alarm?.snoozeMinutes ?? 5;
    days = [...?alarm?.days];
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: time);
    if (picked != null) setState(() => time = picked);
  }

  void _save() {
    final now = DateTime.now();
    Navigator.of(context).pop(AlarmItem(
      id: widget.alarm?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      time: DateTime(now.year, now.month, now.day, time.hour, time.minute),
      name: nameController.text.trim().isEmpty ? 'Alarm' : nameController.text.trim(),
      repeat: repeat,
      days: days,
      sound: sound,
      snoozeMinutes: snooze,
      enabled: widget.alarm?.enabled ?? true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.alarm == null ? 'Add alarm' : 'Edit alarm')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        InkWell(onTap: _pickTime, child: Center(child: Text(time.format(context), style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)))),
        const SizedBox(height: 28),
        TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Alarm name', prefixIcon: Icon(Icons.label_outline))),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(initialValue: repeat, decoration: const InputDecoration(labelText: 'Repeat'), items: ['Once', 'Every day', 'Weekdays', 'Weekends', 'Custom days'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) => setState(() => repeat = value ?? 'Once')),
        if (repeat == 'Custom days') ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: List.generate(
              7,
              (index) => FilterChip(
                label: Text(_day(index)),
                selected: days.contains(index + 1),
                onSelected: (selected) {
                  setState(() {
                    selected ? days.add(index + 1) : days.remove(index + 1);
                  });
                },
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(initialValue: sound, decoration: const InputDecoration(labelText: 'Alarm sound'), items: ['Default', 'Alarm Sound 1', 'Alarm Sound 2', 'Alarm Sound 3'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) => setState(() => sound = value ?? 'Default')),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(initialValue: snooze, decoration: const InputDecoration(labelText: 'Snooze duration'), items: [5, 10, 15].map((value) => DropdownMenuItem(value: value, child: Text('$value minutes'))).toList(), onChanged: (value) => setState(() => snooze = value ?? 5)),
        const SizedBox(height: 28),
        FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check), label: const Text('Save alarm')),
      ]),
    );
  }
}

String _day(int index) => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];