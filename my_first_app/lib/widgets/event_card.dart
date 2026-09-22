import 'package:flutter/material.dart';

import '../models/event.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.onEdit, required this.onDelete});

  final CalendarEvent event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(child: Icon(Icons.event, color: theme.colorScheme.primary)),
        title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${_formatDate(event.date)}\n${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}'),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

String _formatTime(DateTime date) {
  final hour = date.hour == 0 || date.hour == 12 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${date.hour >= 12 ? 'PM' : 'AM'}';
}