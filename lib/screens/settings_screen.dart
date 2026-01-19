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
              title: Text(l10n.settings),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(context, l10n.appearance, [
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  final theme = Theme.of(context);
                  final isDark = theme.brightness == Brightness.dark;
                  return ListTile(
                    leading: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: isDark ? Colors.white : Colors.orange,
                    ),
                    title: Text(l10n.darkMode),
                    trailing: _buildModernSystemSwitch(
                      context,
                      settings.isDarkMode,
                      (v) => settings.toggleTheme(),
                      isDark,
                    ),
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  final theme = Theme.of(context);
                  final isDark = theme.brightness == Brightness.dark;
                  final currentLocale = settings.locale.languageCode;
                  
                  return ListTile(
                    leading: Icon(Icons.language, color: theme.colorScheme.primary),
                    title: Text(l10n.language),
                    trailing: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black : theme.colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.2) : theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLangToggleItem(context, 'ar', 'العربية', currentLocale == 'ar', isDark),
                          _buildLangToggleItem(context, 'en', 'EN', currentLocale == 'en', isDark),
                        ],
                      ),
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
                  final isDark = theme.brightness == Brightness.dark;
                  return ListTile(
                    leading: Icon(
                      settings.notificationsEnabled 
                        ? Icons.notifications_active_rounded 
                        : Icons.notifications_none_rounded, 
                      color: settings.notificationsEnabled ? theme.colorScheme.primary : theme.hintColor
                    ),
                    title: Text(l10n.enableNotifications),
                    trailing: _buildModernSystemSwitch(
                      context,
                      settings.notificationsEnabled,
                      (v) => settings.setNotificationsEnabled(v),
                      isDark,
                    ),
                  );
                },
              ),
              Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  final theme = Theme.of(context);
                  final isDark = theme.brightness == Brightness.dark;
                  return ListTile(
                    leading: Icon(
                      settings.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded, 
                      color: settings.soundEnabled ? theme.colorScheme.primary : theme.hintColor
                    ),
                    title: Text(l10n.soundEffects),
                    trailing: _buildModernSystemSwitch(
                      context,
                      settings.soundEnabled,
                      (v) => settings.setSoundEnabled(v),
                      isDark,
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
    ),
    ],
    ),
      );
    
  }

  Widget _buildModernSystemSwitch(BuildContext context, bool value, ValueChanged<bool> onChanged, bool isDark) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 54,
        height: 30,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value 
              ? (isDark ? Colors.black : theme.colorScheme.primary.withValues(alpha: 0.1)) 
              : (isDark ? Colors.black : Colors.grey.withValues(alpha: 0.1)),
          border: Border.all(
            color: isDark 
                ? (value ? Colors.white : Colors.white.withValues(alpha: 0.2)) 
                : (value ? theme.colorScheme.primary : Colors.grey.withValues(alpha: 0.3)),
            width: 1.5,
          ),
          boxShadow: value && isDark ? [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.1),
              blurRadius: 10,
            )
          ] : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value 
                  ? (isDark ? Colors.white : theme.colorScheme.primary) 
                  : (isDark ? Colors.white.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.4)),
              boxShadow: value && isDark ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 12,
                )
              ] : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangToggleItem(BuildContext context, String code, String label, bool isSelected, bool isDark) {
    final theme = Theme.of(context);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    
    return GestureDetector(
      onTap: () => settings.setLocale(Locale(code)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? Colors.white : theme.colorScheme.primary) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected && isDark ? [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.3),
              blurRadius: 8,
            )
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? (isDark ? Colors.black : Colors.white) 
                : (isDark ? Colors.white.withValues(alpha: 0.5) : theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
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

