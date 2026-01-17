import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medremind/l10n/app_localizations.dart';
import '../models/medication.dart';
import '../providers/calendar_provider.dart';

class MedicationDetailScreen extends StatefulWidget {
  final Medication medication;

  const MedicationDetailScreen({super.key, required this.medication});

  @override
  State<MedicationDetailScreen> createState() => _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends State<MedicationDetailScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medicationDetails),
        centerTitle: true,
      ),
      body: Consumer<CalendarProvider>(
        builder: (context, calProvider, child) {
          final now = DateTime.now();
          final todayOccurrences = widget.medication.getOccurrencesForDay(now);
          todayOccurrences.sort();

          final timesTaken = calProvider.completionsFor(now, widget.medication.id!);
          
          DateTime? nextPending;
          if (timesTaken < todayOccurrences.length) {
            nextPending = todayOccurrences[timesTaken];
          }

          // Decide if we should show the "Due" card
          // Window: if scheduled time is within 60 minutes in the future OR already passed
          bool isDue = false;
          if (nextPending != null) {
            final diff = nextPending.difference(now);
            if (diff.inMinutes <= 60) {
              isDue = true;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDue && nextPending != null) ...[
                  _buildDueCard(context, nextPending, calProvider, l10n),
                  const SizedBox(height: 24),
                ],

                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.medication,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                _buildSectionHeader(context, l10n.stepBasicInfo, Icons.info_outline),
                _buildDetailCard(
                  context,
                  title: l10n.medicationName,
                  value: widget.medication.name,
                  icon: Icons.label,
                ),
                _buildDetailCard(
                  context,
                  title: l10n.dosage,
                  value: widget.medication.dosage,
                  icon: Icons.scale,
                ),
                
                const SizedBox(height: 16),
                _buildSectionHeader(context, l10n.medicationSchedule, Icons.schedule),
                if (widget.medication.year != null && widget.medication.month != null && widget.medication.day != null)
                  _buildDetailCard(
                    context,
                    title: l10n.doseDate,
                    value: '${widget.medication.year}/${widget.medication.month}/${widget.medication.day}',
                    icon: Icons.event,
                  ),
                _buildDetailCard(
                  context,
                  title: l10n.firstDoseTime,
                  value: widget.medication.timeText.split(' ').last,
                  icon: Icons.access_time,
                ),
                _buildDetailCard(
                  context,
                  title: l10n.dosingSchedule,
                  value: _getFrequencyText(context, widget.medication),
                  icon: Icons.repeat,
                ),
                if (widget.medication.endDate != null)
                  _buildDetailCard(
                    context,
                    title: l10n.stopDate,
                    value: widget.medication.endDate!,
                    icon: Icons.calendar_today,
                  ),
                  
                const SizedBox(height: 16),
                _buildSectionHeader(context, l10n.dosageAndStock, Icons.settings_outlined),
                if (widget.medication.totalPills != null)
                  _buildDetailCard(
                    context,
                    title: l10n.stockAmount,
                    value: widget.medication.totalPills.toString(),
                    icon: Icons.inventory,
                  ),
                _buildDetailCard(
                  context,
                  title: l10n.notificationSound,
                  value: widget.medication.sound ?? l10n.defaultSound,
                  icon: Icons.volume_up,
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildDueCard(BuildContext context, DateTime nextPending, CalendarProvider calProvider, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final countdownColor = _getCountdownColor(nextPending, theme.brightness);
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
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
            color: isDark ? Colors.white.withValues(alpha: 0.15) : theme.colorScheme.onSurface.withValues(alpha: 0.05),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: countdownColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.timer, color: countdownColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.nextDose(widget.medication.name),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      l10n.atTime(DateFormat.Hm(locale).format(nextPending)),
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getCountdownText(nextPending),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: countdownColor,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.white : theme.colorScheme.primary,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: isDark ? 0 : 4,
              ),
              onPressed: () {
                calProvider.addOccurrenceCompletion(DateTime.now(), widget.medication.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.doseLogged)),
                );
              },
              icon: const Icon(Icons.check_circle),
              label: Text(
                l10n.logDoseNow,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context,
      {required String title, required String value, required IconData icon}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isDark ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isDark 
          ? const BorderSide(color: Colors.white, width: 1)
          : BorderSide.none,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  String _getFrequencyText(BuildContext context, Medication med) {
    final l10n = AppLocalizations.of(context)!;
    if (med.frequency == 'Daily' || med.frequency == 'daily') return l10n.daily;
    if (med.frequency == 'Weekly' || med.frequency == 'weekly') return l10n.weekly;
    if (med.frequency == 'Interval' || med.interval != null) {
      return '${l10n.every} ${med.interval} ${_getIntervalUnitText(context, med.intervalUnit)}';
    }
    return med.frequency;
  }

  String _getIntervalUnitText(BuildContext context, String? unit) {
    final l10n = AppLocalizations.of(context)!;
    switch (unit) {
      case 'minutes':
        return l10n.minutes;
      case 'hours':
        return l10n.hours;
      case 'days':
        return l10n.days;
      default:
        return unit ?? '';
    }
  }
}

