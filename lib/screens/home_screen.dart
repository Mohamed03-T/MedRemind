import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/medication_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/calendar_provider.dart';
import '../models/medication.dart';
import 'medication_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CalendarProvider>(context, listen: false).loadForDate(DateTime.now());
    });
    // Refresh every second to update countdowns with seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String _getCountdownText(DateTime scheduledTime) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    final absDiff = difference.abs();

    final hours = absDiff.inHours;
    final minutes = absDiff.inMinutes % 60;
    final seconds = absDiff.inSeconds % 60;
    
    String timeStr = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return difference.isNegative ? '-$timeStr' : timeStr;
  }

  Color _getCountdownColor(DateTime scheduledTime) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    
    if (difference.isNegative) return Colors.red;
    if (difference.inHours >= 1) return Colors.green;
    if (difference.inMinutes >= 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تذكير الدواء'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer2<MedicationProvider, CalendarProvider>(
        builder: (context, medProvider, calProvider, child) {
          final theme = Theme.of(context);
          final now = DateTime.now();
          
          // Get today's occurrences
          final List<DoseOccurrence> todayOccurrences = [];
          for (var med in medProvider.medications) {
            final times = med.getOccurrencesForDay(now);
            for (var time in times) {
              todayOccurrences.add(DoseOccurrence(medication: med, scheduledTime: time));
            }
          }
          
          // Sort by time
          todayOccurrences.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

          // Separate into Pending and Done
          final List<DoseOccurrence> pendingList = [];
          final List<DoseOccurrence> completedList = [];
          
          final Map<int, int> medCounts = {};
          for (var occ in todayOccurrences) {
            final medId = occ.medication.id!;
            final currentCount = medCounts[medId] ?? 0;
            final timesTaken = calProvider.completionsFor(now, medId);
            
            if (currentCount < timesTaken) {
              completedList.add(occ);
            } else {
              pendingList.add(occ);
            }
            medCounts[medId] = currentCount + 1;
          }

          // Find Next Dose (first pending one after current time)
          DoseOccurrence? nextDose;
          for (var occ in pendingList) {
            if (occ.scheduledTime.isAfter(now)) {
              nextDose = occ;
              break;
            }
          }

          return CustomScrollView(
            slivers: [
              // Statistics Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _buildStatCard(
                        context,
                        'الإجمالي',
                        todayOccurrences.length.toString(),
                        Icons.medication,
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context,
                        'أخذت',
                        completedList.length.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context,
                        'متبقية',
                        pendingList.length.toString(),
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
              if (nextDose != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.timer, color: theme.colorScheme.primary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الجرعة القادمة: ${nextDose.medication.name}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    'في تمام الساعة ${DateFormat.Hm().format(nextDose.scheduledTime)}',
                                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _getCountdownColor(nextDose.scheduledTime).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getCountdownText(nextDose.scheduledTime),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: _getCountdownColor(nextDose.scheduledTime),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Pending Section
              if (pendingList.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 8),
                      child: Text(
                        'الجرعات المتبقية لليوم',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildDoseItem(context, pendingList[index], false),
                      childCount: pendingList.length,
                    ),
                  ),
                ),
              ],

              // Completed Section
              if (completedList.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32, bottom: 8),
                      child: Text(
                        'الجرعات التي تم أخذها',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildDoseItem(context, completedList[index], true),
                      childCount: completedList.length,
                    ),
                  ),
                ),
              ],

              if (todayOccurrences.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medication_outlined, size: 64, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد جرعات مجدولة لليوم',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoseItem(BuildContext context, DoseOccurrence occ, bool isDone) {
    final theme = Theme.of(context);
    final med = occ.medication;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDone ? Colors.green.withValues(alpha: 0.1) : theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicationDetailScreen(medication: med),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Time Indicator
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isDone ? Colors.green.withValues(alpha: 0.1) : theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat.Hm().format(occ.scheduledTime),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDone ? Colors.green : theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      DateFormat('a', 'ar').format(occ.scheduledTime),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDone ? Colors.green : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Med info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            med.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                              color: isDone
                                  ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                                  : theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          med.dosage,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                    if (!isDone) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 14, color: _getCountdownColor(occ.scheduledTime).withValues(alpha: 0.5)),
                          const SizedBox(width: 4),
                          Text(
                            _getCountdownText(occ.scheduledTime),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _getCountdownColor(occ.scheduledTime),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Status Icon instead of check action
              Icon(
                isDone ? Icons.check_circle : Icons.chevron_right,
                color: isDone ? Colors.green : theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
