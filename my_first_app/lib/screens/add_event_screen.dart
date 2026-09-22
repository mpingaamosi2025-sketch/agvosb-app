import 'package:flutter/material.dart';

import '../models/event.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key, this.event, this.initialDate});

  final CalendarEvent? event;
  final DateTime? initialDate;

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late DateTime date;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  int reminder = 0;
  String repeat = 'Never';

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    titleController = TextEditingController(text: event?.title ?? '');
    descriptionController = TextEditingController(text: event?.description ?? '');
    date = event?.date ?? widget.initialDate ?? DateTime.now();
    startTime = TimeOfDay.fromDateTime(event?.startTime ?? DateTime.now());
    endTime = TimeOfDay.fromDateTime(event?.endTime ?? DateTime.now().add(const Duration(hours: 1)));
    reminder = event?.reminder ?? 0;
    repeat = event?.repeat ?? 'Never';
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: date);
    if (picked != null) setState(() => date = picked);
  }

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(context: context, initialTime: start ? startTime : endTime);
    if (picked != null) setState(() => start ? startTime = picked : endTime = picked);
  }

  void _save() {
    if (titleController.text.trim().isEmpty) return;
    DateTime at(TimeOfDay time) => DateTime(date.year, date.month, date.day, time.hour, time.minute);
    Navigator.of(context).pop(CalendarEvent(
      id: widget.event?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      date: DateTime(date.year, date.month, date.day),
      startTime: at(startTime),
      endTime: at(endTime),
      reminder: reminder,
      repeat: repeat,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event == null ? 'Add event' : 'Edit event')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        TextField(controller: titleController, autofocus: true, decoration: const InputDecoration(labelText: 'Event title', prefixIcon: Icon(Icons.title))),
        const SizedBox(height: 14),
        TextField(controller: descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true, prefixIcon: Icon(Icons.notes))),
        const SizedBox(height: 18),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_today), title: const Text('Date'), subtitle: Text('${date.day} ${_month(date.month)} ${date.year}'), onTap: _pickDate),
        Row(children: [
          Expanded(child: ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.schedule), title: const Text('Starts'), subtitle: Text(startTime.format(context)), onTap: () => _pickTime(start: true))),
          Expanded(child: ListTile(contentPadding: EdgeInsets.zero, title: const Text('Ends'), subtitle: Text(endTime.format(context)), onTap: () => _pickTime(start: false))),
        ]),
        DropdownButtonFormField<int>(initialValue: reminder, decoration: const InputDecoration(labelText: 'Reminder'), items: const [DropdownMenuItem(value: 0, child: Text('At event time')), DropdownMenuItem(value: 5, child: Text('5 minutes before')), DropdownMenuItem(value: 10, child: Text('10 minutes before')), DropdownMenuItem(value: 15, child: Text('15 minutes before')), DropdownMenuItem(value: 30, child: Text('30 minutes before')), DropdownMenuItem(value: 60, child: Text('1 hour before')), DropdownMenuItem(value: 1440, child: Text('1 day before'))], onChanged: (value) => setState(() => reminder = value ?? 0)),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(initialValue: repeat, decoration: const InputDecoration(labelText: 'Repeat'), items: ['Never', 'Every day', 'Every week', 'Every month'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) => setState(() => repeat = value ?? 'Never')),
        const SizedBox(height: 28),
        FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check), label: const Text('Save event')),
      ]),
    );
  }
}

String _month(int month) => const ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][month - 1];