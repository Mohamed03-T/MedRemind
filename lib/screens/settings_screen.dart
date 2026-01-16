import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medremind/l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(context, l10n.appearance, [
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  final theme = Theme.of(context);
                  return ListTile(
                    leading: Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
                    title: Text(l10n.darkMode),
                    trailing: Switch(
                      value: settings.isDarkMode,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (v) => settings.toggleTheme(),
                    ),
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  final theme = Theme.of(context);
                  return ListTile(
                    leading: Icon(Icons.language, color: theme.colorScheme.primary),
                    title: Text(l10n.language),
                    trailing: DropdownButton<String>(
                      value: settings.locale.languageCode,
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          settings.setLocale(Locale(newValue));
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 'ar', child: Text('العربية')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),
            _buildSection(context, l10n.notifications, [
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  final theme = Theme.of(context);
                  return ListTile(
                    leading: Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary),
                    title: Text(l10n.enableNotifications),
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
                    title: Text(l10n.soundEffects),
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
            _buildSection(context, l10n.account, [
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  final theme = Theme.of(context);
                  return ListTile(
                    leading: Icon(Icons.person_outline, color: theme.colorScheme.primary),
                    title: Text(l10n.userName),
                    subtitle: Text(settings.userName.isEmpty ? l10n.notSet : settings.userName),
                    trailing: Icon(Icons.edit_outlined, size: 20, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    onTap: () => _editUserName(context, settings, l10n),
                  );
                },
              ),
            ]),
            const SizedBox(height: 20),
            _buildSection(context, l10n.more, [
              ListTile(
                leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                title: Text(l10n.aboutApp),
                trailing: Icon(Localizations.localeOf(context).languageCode == 'ar' ? Icons.chevron_left : Icons.chevron_right),
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AboutScreen()),
                      );
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/photos/LOGO.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(l10n.version, style: const TextStyle(color: Colors.grey)),
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

  void _editUserName(BuildContext context, SettingsProvider settings, AppLocalizations l10n) {
    final controller = TextEditingController(text: settings.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editName),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.enterName),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              settings.setUserName(controller.text);
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

