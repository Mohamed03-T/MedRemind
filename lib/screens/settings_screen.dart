import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(context, 'المظهر', [
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  final theme = Theme.of(context);
                  return ListTile(
                    leading: Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
                    title: const Text('الوضع الداكن'),
                    trailing: Switch(
                      value: settings.isDarkMode,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (v) => settings.toggleTheme(),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),
            _buildSection(context, 'التنبيهات', [
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  final theme = Theme.of(context);
                  return ListTile(
                    leading: Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary),
                    title: const Text('تشغيل التنبيهات'),
                    trailing: Switch(
                      value: settings.notificationsEnabled,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (v) => settings.setNotificationsEnabled(v),
                    ),
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  final theme = Theme.of(context);
                  return ListTile(
                    leading: Icon(Icons.volume_up_outlined, color: theme.colorScheme.primary),
                    title: const Text('المؤثرات الصوتية'),
                    trailing: Switch(
                      value: settings.soundEnabled,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (v) => settings.setSoundEnabled(v),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),
            _buildSection(context, 'الحساب', [
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  final theme = Theme.of(context);
                  return ListTile(
                    leading: Icon(Icons.person_outline, color: theme.colorScheme.primary),
                    title: const Text('اسم المستخدم'),
                    subtitle: Text(settings.userName.isEmpty ? 'لم يتم التحديد' : settings.userName),
                    trailing: Icon(Icons.edit_outlined, size: 20, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    onTap: () => _editUserName(context, settings),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),
            _buildSection(context, 'المزيد', [
              ListTile(
                leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                title: const Text('عن التطبيق'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                },
              ),
            ]),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  const Text('تذكير الدواء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text('إصدار 1.0.0', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  void _editUserName(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(text: settings.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الاسم'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'أدخل اسمك هنا'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              settings.setUserName(controller.text);
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
