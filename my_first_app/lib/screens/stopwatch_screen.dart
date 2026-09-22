import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch stopwatch = Stopwatch();
  final List<Duration> laps = [];
  Timer? ticker;

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  void toggle() {
    setState(() {
      if (stopwatch.isRunning) {
        stopwatch.stop();
        ticker?.cancel();
      } else {
        stopwatch.start();
        ticker = Timer.periodic(const Duration(milliseconds: 30), (_) => setState(() {}));
      }
    });
  }

  void reset() {
    setState(() {
      stopwatch.reset();
      laps.clear();
    });
  }

  String format(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final hundredths = (duration.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds.$hundredths';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 42),
        Center(child: Text(format(stopwatch.elapsed), style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, fontFeatures: const [FontFeature.tabularFigures()]))),
        const SizedBox(height: 42),
        FilledButton.icon(onPressed: toggle, icon: Icon(stopwatch.isRunning ? Icons.pause : Icons.play_arrow), label: Text(stopwatch.isRunning ? 'Pause' : stopwatch.elapsed > Duration.zero ? 'Resume' : 'Start')),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: stopwatch.elapsed == Duration.zero ? null : () => setState(() => laps.add(stopwatch.elapsed)), icon: const Icon(Icons.flag), label: const Text('Lap'))),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton.icon(onPressed: reset, icon: const Icon(Icons.refresh), label: const Text('Reset'))),
        ]),
        const SizedBox(height: 32),
        if (laps.isNotEmpty) ...[
          Text('Laps', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const Divider(),
          ...laps.asMap().entries.map((entry) => ListTile(leading: Text('Lap ${entry.key + 1}'), trailing: Text(format(entry.value), style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])))),
        ],
      ]),
    );
  }
}