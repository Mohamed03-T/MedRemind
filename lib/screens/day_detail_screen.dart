import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:medremind/l10n/app_localizations.dart';
import '../models/medication.dart';
import '../providers/calendar_provider.dart';
import 'medication_detail_screen.dart';

class DayDetailScreen extends StatelessWidget {
  final DateTime date;
  final List<DoseOccurrence> occurrences;

  const DayDetailScreen({
    super.key,
    required this.date,
    required this.occurrences,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
            appBar: AppBar(
              title: Text(DateFormat.yMMMMd(l10n.localeName).format(date)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            body: occurrences.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        l10n.noTasks,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: occurrences.length,
                    itemBuilder: (context, index) {
                      final occ = occurrences[index];
                      final med = occ.medication;
                      return Consumer<CalendarProvider>(
                        builder: (context, cal, _) {
                          final int timesTaken = cal.completionsFor(date, med.id!);
                          final int medOccurrenceIndex = occurrences.sublist(0, index).where((o) => o.medication.id == med.id).length;
                          final bool isDone = medOccurrenceIndex < timesTaken;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MedicationDetailScreen(medication: med)),
                              ),
                              leading: Container(
                                width: 76,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDone ? Colors.green.withValues(alpha: 0.08) : theme.colorScheme.primary.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(DateFormat.Hm().format(occ.scheduledTime), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(DateFormat('a', l10n.localeName).format(occ.scheduledTime), style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 11)),
                                  ],
                                ),
                              ),
                              title: Text(med.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDone ? theme.colorScheme.onSurface.withValues(alpha: 0.4) : theme.colorScheme.onSurface)),
                              subtitle: Text(med.dosage, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                              trailing: isDone ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.chevron_right),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
