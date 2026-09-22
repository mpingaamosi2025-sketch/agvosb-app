import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.isDarkMode, required this.onFinished});

  final bool isDarkMode;
  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Timer _timer;
  int _index = 0;
  final List<String> _wordSequence = ['A', 'Ag', 'AgV', 'AgVo', 'AgVos', 'AgVosb'];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) return;
      if (_index < _wordSequence.length - 1) {
        setState(() => _index++);
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 250), widget.onFinished);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = _wordSequence[_index];
    final bg = widget.isDarkMode ? const Color(0xFF0B1220) : const Color(0xFFF5F9FF);
    final card = widget.isDarkMode ? const Color(0xFF101826) : Colors.white;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: bg,
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 400),
            scale: 1,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: card,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/image/agvosb_logo.png', width: 44, height: 44),
                    const SizedBox(width: 12),
                    Text(
                      text,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: widget.isDarkMode ? Colors.white : const Color(0xFF0E2136),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
