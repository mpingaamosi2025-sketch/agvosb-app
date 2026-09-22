import 'package:flutter/material.dart';

import '../models/alarm.dart';
import '../widgets/alarm_card.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key, required this.alarms, required this.onAdd, required this.onEdit, required this.onDelete, required this.onToggle});

  final List<AlarmItem> alarms;
  final ValueChanged<AlarmItem?> onAdd;
  final ValueChanged<AlarmItem> onEdit;
  final ValueChanged<AlarmItem> onDelete;
  final void Function(AlarmItem, bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarm')),
      body: alarms.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.alarm_add, size: 56), const SizedBox(height: 12), const Text('No alarms yet'), const SizedBox(height: 16), FilledButton.icon(onPressed: () => onAdd(null), icon: const Icon(Icons.add), label: const Text('Create alarm'))]))
          : ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), children: [Text('${alarms.length} alarm${alarms.length == 1 ? '' : 's'}', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 10), ...alarms.map((alarm) => AlarmCard(alarm: alarm, onChanged: (value) => onToggle(alarm, value), onEdit: () => onEdit(alarm), onDelete: () => onDelete(alarm))) ]),
      floatingActionButton: alarms.isEmpty ? null : FloatingActionButton.extended(onPressed: () => onAdd(null), icon: const Icon(Icons.add), label: const Text('Add alarm')),
    );
  }
}
