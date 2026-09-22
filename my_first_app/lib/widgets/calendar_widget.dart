import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.today,
    required this.firstDayOfWeek,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDateSelected,
  });

  final DateTime displayedMonth;
  final DateTime selectedDate;
  final DateTime today;
  final int firstDayOfWeek;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstDayOffset =
        (DateTime(displayedMonth.year, displayedMonth.month, 1).weekday - firstDayOfWeek + 7) % 7;
    final daysInMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;
    final weekdayLabels = firstDayOfWeek == DateTime.sunday
        ? ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onPreviousMonth,
                  tooltip: 'Previous month',
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${monthName(displayedMonth.month)} ${displayedMonth.year}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: onNextMonth,
                  tooltip: 'Next month',
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: weekdayLabels
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: firstDayOffset + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                if (index < firstDayOffset) return const SizedBox.shrink();

                final date = DateTime(
                  displayedMonth.year,
                  displayedMonth.month,
                  index - firstDayOffset + 1,
                );
                final isToday = isSameDate(date, today);
                final isSelected = isSameDate(date, selectedDate);

                return InkWell(
                  onTap: () => onDateSelected(date),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isToday
                              ? theme.colorScheme.primaryContainer
                              : null,
                      borderRadius: BorderRadius.circular(10),
                      border: isToday && !isSelected
                          ? Border.all(color: theme.colorScheme.primary)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                        fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

String monthName(int month) {
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return months[month - 1];
}

bool isSameDate(DateTime first, DateTime second) {
  return first.year == second.year && first.month == second.month && first.day == second.day;
}