import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medication.dart';
import '../providers/calendar_provider.dart';

class MedicationDetailScreen extends StatelessWidget {
  final Medication medication;

  const MedicationDetailScreen({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الدواء'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            
            _buildSectionHeader(context, 'المعلومات الأساسية', Icons.info_outline),
            _buildDetailCard(
              context,
              title: 'اسم الدواء',
              value: medication.name,
              icon: Icons.label,
            ),
            _buildDetailCard(
              context,
              title: 'الجرعة',
              value: medication.dosage,
              icon: Icons.scale,
            ),
            
            const SizedBox(height: 16),
            _buildSectionHeader(context, 'المواعيد والتكرار', Icons.schedule),
            if (medication.year != null && medication.month != null && medication.day != null)
              _buildDetailCard(
                context,
                title: 'تاريخ لبداية',
                value: '${medication.year}/${medication.month}/${medication.day}',
                icon: Icons.event,
              ),
            _buildDetailCard(
              context,
              title: 'وقت التذكير',
              value: medication.timeText.split(' ').last, // Just the time part
              icon: Icons.access_time,
            ),
            _buildDetailCard(
              context,
              title: 'نظام التكرار',
              value: _getFrequencyText(medication),
              icon: Icons.repeat,
            ),
            if (medication.endDate != null)
              _buildDetailCard(
                context,
                title: 'تاريخ الانتهاء المتوقع',
                value: medication.endDate!,
                icon: Icons.calendar_today,
              ),
              
            const SizedBox(height: 16),
            _buildSectionHeader(context, 'الإعدادات والمخزون', Icons.settings_outlined),
            if (medication.totalPills != null)
              _buildDetailCard(
                context,
                title: 'إجمالي الكمية المتوفرة',
                value: medication.totalPills.toString(),
                icon: Icons.inventory,
              ),
            _buildDetailCard(
              context,
              title: 'صوت التنبيه',
              value: medication.sound ?? 'النغمة الافتراضية',
              icon: Icons.volume_up,
            ),

            const SizedBox(height: 32),
            // Action Button
            Consumer<CalendarProvider>(
              builder: (context, calProvider, child) {
                final now = DateTime.now();
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 5,
                    ),
                    onPressed: () {
                      calProvider.addOccurrenceCompletion(now, medication.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تسجيل أخذ الجرعة بنجاح')),
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text(
                      'تسجيل أخذ الجرعة الآن',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 8),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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

  String _getFrequencyText(Medication med) {
    if (med.frequency == 'Daily') return 'يومياً';
    if (med.frequency == 'Weekly') return 'أسبوعياً';
    if (med.frequency == 'Interval') {
      return 'كل ${med.interval} ${_getIntervalUnitText(med.intervalUnit)}';
    }
    return med.frequency;
  }

  String _getIntervalUnitText(String? unit) {
    switch (unit) {
      case 'minutes':
        return 'دقائق';
      case 'hours':
        return 'ساعات';
      case 'days':
        return 'أيام';
      default:
        return unit ?? '';
    }
  }
}
