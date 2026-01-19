import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:medremind/l10n/app_localizations.dart';
import '../providers/medication_provider.dart';
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

  String _getCountdownText(DateTime scheduledTime, String langCode) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    final absDiff = difference.abs();

    final hours = absDiff.inHours;
    final minutes = absDiff.inMinutes % 60;
    final seconds = absDiff.inSeconds % 60;
    
    String timeStr = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return difference.isNegative ? '-$timeStr' : timeStr;
  }

  Color _getCountdownColor(DateTime scheduledTime, Brightness brightness) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    final isDark = brightness == Brightness.dark;
    
    if (difference.isNegative) return Colors.red;
    if (difference.inHours >= 1) return isDark ? Colors.green : const Color(0xFF059669);
    if (difference.inMinutes >= 30) return isDark ? Colors.orange : const Color(0xFFD97706);
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
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
            appBar: AppBar(
              title: Text(l10n.appTitle),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            body: Consumer2<MedicationProvider, CalendarProvider>(
              builder: (context, medProvider, calProvider, child) {
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

          final Color statBlue = isDark ? Colors.blue : const Color(0xFF3B82F6);
          final Color statGreen = isDark ? Colors.green : const Color(0xFF10B981);
          final Color statOrange = isDark ? Colors.orange : const Color(0xFFF59E0B);

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
                        l10n.total,
                        todayOccurrences.length.toString(),
                        Icons.medication,
                        statBlue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context,
                        l10n.taken,
                        completedList.length.toString(),
                        Icons.check_circle,
                        statGreen,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context,
                        l10n.remaining,
                        pendingList.length.toString(),
                        Icons.pending_actions,
                        statOrange,
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
                      border: Border.all(
                        color: isDark ? Colors.white : theme.colorScheme.primary.withValues(alpha: 0.1),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.white.withValues(alpha: 0.15) : theme.colorScheme.onSurface.withValues(alpha: 0.03),
                          blurRadius: isDark ? 12 : 15,
                          offset: const Offset(0, 8),
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
                                    l10n.nextDose(nextDose.medication.name),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    l10n.atTime(DateFormat.Hm(locale).format(nextDose.scheduledTime)),
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
                            color: _getCountdownColor(nextDose.scheduledTime, theme.brightness).withValues(alpha: isDark ? 0.05 : 0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getCountdownText(nextDose.scheduledTime, l10n.localeName),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: _getCountdownColor(nextDose.scheduledTime, theme.brightness),
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
                        l10n.remainingDosesToday,
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
                        l10n.takenDosesToday,
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
                          l10n.noDosesToday,
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white : color.withValues(alpha: 0.1),
            width: isDark ? 1.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : theme.shadowColor.withValues(alpha: 0.02),
              blurRadius: isDark ? 8 : 10,
              offset: isDark ? Offset.zero : const Offset(0, 4),
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
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDark ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark 
              ? Colors.white 
              : (isDone ? Colors.green.withValues(alpha: 0.1) : theme.colorScheme.primary.withValues(alpha: 0.1)),
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
                      DateFormat('a', Localizations.localeOf(context).toString()).format(occ.scheduledTime),
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
                          Icon(Icons.timer_outlined, size: 14, color: _getCountdownColor(occ.scheduledTime, theme.brightness).withValues(alpha: 0.5)),
                          const SizedBox(width: 4),
                          Text(
                            _getCountdownText(occ.scheduledTime, l10n.localeName),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _getCountdownColor(occ.scheduledTime, theme.brightness),
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

