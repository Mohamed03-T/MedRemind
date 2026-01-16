import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medremind/l10n/app_localizations.dart';
import '../providers/medication_provider.dart';
import 'medication_detail_screen.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medications),
        centerTitle: true,
      ),
      body: Consumer<MedicationProvider>(
        builder: (context, provider, child) {
          if (provider.medications.isEmpty) {
            return Center(child: Text(l10n.noMedications));
          }

          return ListView.builder(
            itemCount: provider.medications.length,
            itemBuilder: (context, index) {
              final med = provider.medications[index];
              final theme = Theme.of(context);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicationDetailScreen(medication: med),
                      ),
                    );
                  },
                  onLongPress: () {
                    _showActionSheet(context, med, provider);
                  },
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.medication,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    med.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time, size: 16, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                med.timeText,
                                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.scale, size: 16, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                med.dosage,
                                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showActionSheet(BuildContext context, med, MedicationProvider provider) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
              title: Text(AppLocalizations.of(context)!.viewDetails),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicationDetailScreen(medication: med),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined, color: Colors.orange),
              title: Text(AppLocalizations.of(context)!.updateStock),
              subtitle: Text(med.localeStockText(Localizations.localeOf(context).languageCode)),
              onTap: () {
                Navigator.pop(context);
                _showUpdateStockDialog(context, med, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(AppLocalizations.of(context)!.deleteMedication, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(context, med, provider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context, med, MedicationProvider provider) {
    final containerController = TextEditingController(text: '1');
    final unitsController = TextEditingController(text: '30');
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          void updateVal(TextEditingController controller, int delta) {
            int current = int.tryParse(controller.text) ?? 0;
            int newValue = current + delta;
            if (newValue < 0) newValue = 0;
            setDialogState(() {
              controller.text = newValue.toString();
            });
          }

          int packCount = int.tryParse(containerController.text) ?? 0;
          int unitCount = int.tryParse(unitsController.text) ?? 0;
          int totalToAdd = packCount * unitCount;
          int currentStock = med.totalPills ?? 0;
          int finalStock = currentStock + totalToAdd;

          final l10n = AppLocalizations.of(context)!;
          final unit = med.dosage.split(' ').length > 1 ? med.dosage.split(' ').last : l10n.unit;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            backgroundColor: theme.colorScheme.surface,
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.inventory_2_outlined, color: theme.colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Text(l10n.updateStock, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  _buildElegantControl(
                    theme, 
                    containerController, 
                    l10n.howManyBoxes, 
                    Icons.inventory_2_outlined, 
                    () => updateVal(containerController, -1),
                    () => updateVal(containerController, 1)
                  ),
                  const SizedBox(height: 12),
                  _buildElegantControl(
                    theme, 
                    unitsController, 
                    l10n.howManyUnitsPerBox, 
                    Icons.local_pharmacy, 
                    () => updateVal(unitsController, -1),
                    () => updateVal(unitsController, 1)
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.currentStockLabel, style: const TextStyle(fontSize: 13)),
                            Text('$currentStock $unit', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.addedAmountLabel, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500)),
                            Text('+$totalToAdd $unit', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(thickness: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.newStockLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('$finalStock $unit', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 20)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel, style: TextStyle(color: theme.colorScheme.secondary)),
              ),
              FilledButton(
                onPressed: () {
                  provider.updatePillCount(med.id!, finalStock);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      content: Text(l10n.stockUpdateSuccess(finalStock, unit)),
                    ),
                  );
                },
                child: Text(l10n.saveUpdate),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildElegantControl(ThemeData theme, TextEditingController controller, String label, IconData icon, VoidCallback onSub, VoidCallback onAdd) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 6),
          child: Text(label, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w500)),
        ),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(icon, size: 20, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onSub,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.remove_rounded, color: theme.colorScheme.error),
                  ),
                ),
              ),
              const VerticalDivider(width: 1, indent: 15, endIndent: 15),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.add_rounded, color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, med, MedicationProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMedication),
        content: Text(l10n.localeDeleteQuery(med.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.deleteMedication(med.id!);
              Navigator.pop(context);
            },
            child: Text(l10n.deleteMedication, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

