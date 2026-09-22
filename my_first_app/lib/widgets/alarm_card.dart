import 'package:flutter/material.dart';

import '../models/alarm.dart';

class AlarmCard extends StatelessWidget {
  const AlarmCard({super.key, required this.alarm, required this.onChanged, required this.onEdit, required this.onDelete});

  final AlarmItem alarm;
  final ValueChanged<bool> onChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: const CircleAvatar(child: Icon(Icons.alarm)),
        title: Text(_formatTime(alarm.time), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        subtitle: Text('${alarm.name}\n${alarm.repeat}'),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: alarm.enabled, onChanged: onChanged),
            PopupMenuButton<String>(
              onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime time) {
  final hour = time.hour == 0 || time.hour == 12 ? 12 : time.hour % 12;
  return '$hour:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';
}