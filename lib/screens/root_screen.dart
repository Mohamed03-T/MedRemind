import 'package:flutter/material.dart';
import 'package:medremind/l10n/app_localizations.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'medications_screen.dart';
import 'settings_screen.dart';
import 'add_medication_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    CalendarScreen(),
    MedicationsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.5,
                  widthFactor: 1.0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: isDark
                        ? RadialGradient(
                            center: const Alignment(0.0, 1.0),
                            radius: 1.5,
                            colors: [
                              Colors.white.withValues(alpha: 0.18),
                              Colors.grey.withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          )
                        : RadialGradient(
                            center: const Alignment(0.0, 1.0),
                            radius: 2.0,
                            colors: [
                              Colors.black.withValues(alpha: 0.04),
                              Colors.grey.withValues(alpha: 0.02),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Scaffold(
            backgroundColor: Colors.transparent,
            body: _pages[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
                BottomNavigationBarItem(icon: const Icon(Icons.calendar_today), label: l10n.calendar),
                BottomNavigationBarItem(icon: const Icon(Icons.medication), label: l10n.medications),
                BottomNavigationBarItem(icon: const Icon(Icons.settings), label: l10n.settings),
              ],
            ),
            floatingActionButton: _currentIndex == 2
                ? FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddMedicationScreen()),
                      );
                    },
                    child: const Icon(Icons.add),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

