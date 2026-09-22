import 'package:flutter/material.dart';

import '../models/event.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/event_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, required this.firstDayOfWeek, required this.events, required this.onAddEvent, required this.onEditEvent, required this.onDeleteEvent});

  final int firstDayOfWeek;
  final List<CalendarEvent> events;
  final ValueChanged<DateTime> onAddEvent;
  final ValueChanged<CalendarEvent> onEditEvent;
  final ValueChanged<CalendarEvent> onDeleteEvent;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime displayedMonth;
  late DateTime selectedDate;
  final DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    displayedMonth = DateTime(today.year, today.month);
    selectedDate = DateTime(today.year, today.month, today.day);
  }

  void changeMonth(int amount) => setState(() => displayedMonth = DateTime(displayedMonth.year, displayedMonth.month + amount));

  void showToday() => setState(() {
        displayedMonth = DateTime(today.year, today.month);
        selectedDate = DateTime(today.year, today.month, today.day);
      });

  @override
  Widget build(BuildContext context) {
    final selectedEvents = widget.events.where((event) => isSameDate(event.date, selectedDate)).toList();
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverAppBar(pinned: true, title: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.asset('assets/image/agvosb_logo.png', width: 32, height: 32)), const SizedBox(width: 10), const Text('AgVosb')]), actions: [TextButton(onPressed: showToday, child: const Text('Today'))]),
          SliverPadding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 100), sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(weekdayName(today.weekday), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('${today.day} ${monthName(today.month)} ${today.year}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            CalendarWidget(displayedMonth: displayedMonth, selectedDate: selectedDate, today: today, firstDayOfWeek: widget.firstDayOfWeek, onPreviousMonth: () => changeMonth(-1), onNextMonth: () => changeMonth(1), onDateSelected: (date) => setState(() => selectedDate = date)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Events for ${selectedDate.day} ${monthName(selectedDate.month)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)), IconButton(onPressed: () => widget.onAddEvent(selectedDate), icon: const Icon(Icons.add), tooltip: 'Add event')]),
            const SizedBox(height: 8),
            if (selectedEvents.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No events for this day'))),
            ...selectedEvents.map((event) => EventCard(event: event, onEdit: () => widget.onEditEvent(event), onDelete: () => widget.onDeleteEvent(event))),
          ]))),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => widget.onAddEvent(selectedDate), icon: const Icon(Icons.add), label: const Text('Add event')),
    );
  }
}

String weekdayName(int weekday) => const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][weekday - 1];
