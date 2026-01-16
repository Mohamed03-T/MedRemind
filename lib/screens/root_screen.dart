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
    return Scaffold(
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
    );
  }
}

