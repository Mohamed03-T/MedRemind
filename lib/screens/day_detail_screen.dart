import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Hero(
        tag: 'day_$date',
        child: Material(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 150,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    DateFormat.yMMMMd('ar').format(date),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                ),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (occurrences.isEmpty) {
                        return Center(child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'لا يوجد مهام لهذا اليوم', 
                            style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        ));
                      }
                      
                      // Sort occurrences by time
                      final sortedOccs = List<DoseOccurrence>.from(occurrences)
                        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
                      
                      final occ = sortedOccs[index];
                      final med = occ.medication;

                      return Consumer<CalendarProvider>(
                        builder: (context, cal, _) {
                          final int timesTaken = cal.completionsFor(date, med.id!);
                          final int medOccurrenceIndex = sortedOccs.sublist(0, index).where((o) => o.medication.id == med.id).length;
                          final bool isDone = medOccurrenceIndex < timesTaken;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadowColor.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MedicationDetailScreen(medication: med),
                                  ),
                                );
                              },
                              leading: Checkbox(
                                value: isDone,
                                activeColor: theme.colorScheme.primary,
                                onChanged: (_) async {
                                  final now = DateTime.now();
                                  if (isDone) {
                                    cal.toggleCompletion(date, med.id!);
                                    return;
                                  }

                                  // If scheduled time is in the future, confirm with user
                                  if (occ.scheduledTime.isAfter(now)) {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('تأكيد'),
                                        content: const Text('لم يحن وقت هذه الجرعة بعد. هل تريد شطبها على أي حال؟'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(ctx).pop(false),
                                            child: const Text('إلغاء'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(ctx).pop(true),
                                            child: const Text('شطب'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm != true) return;
                                  }

                                  cal.addOccurrenceCompletion(date, med.id!);
                                },
                              ),
                              title: Text(
                                med.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                  color: isDone ? theme.colorScheme.onSurface.withValues(alpha: 0.4) : theme.colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.access_time, size: 14, color: theme.colorScheme.primary),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              DateFormat.Hm().format(occ.scheduledTime),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.medication_liquid_sharp, size: 14, color: theme.colorScheme.secondary),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              med.dosage,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: isDone 
                                  ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                                  : const Icon(Icons.pending_actions, color: Colors.orange, size: 28),
                            ),
                          );
                        },
                      );
                    },
                    childCount: occurrences.isEmpty ? 1 : occurrences.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
