import 'package:flutter/material.dart';
import 'package:medremind/l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
              title: Text(l10n.aboutApp),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Credit
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.transparent,
                ),
                boxShadow: theme.brightness == Brightness.dark ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 10,
                  )
                ] : null,
              ),
              child: Text(
                'MOHAMED TOUTI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.brightness == Brightness.dark ? Colors.white : theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
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
            const SizedBox(height: 24),
            Text(
              l10n.appTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.appSlogan,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 40),
            _buildFeatureItem(
              context,
              Icons.notifications_active,
              l10n.feature1Title,
              l10n.feature1Desc,
            ),
            _buildFeatureItem(
              context,
              Icons.calendar_month,
              l10n.feature2Title,
              l10n.feature2Desc,
            ),
            _buildFeatureItem(
              context,
              Icons.security,
              l10n.feature3Title,
              l10n.feature3Desc,
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              l10n.developedWithLove,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.version,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String description) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? Colors.black : theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.brightness == Brightness.dark ? Colors.white : Colors.transparent,
                width: theme.brightness == Brightness.dark ? 1 : 0,
              ),
              boxShadow: theme.brightness == Brightness.dark ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 8,
                )
              ] : null,
            ),
            child: Icon(icon, color: theme.brightness == Brightness.dark ? Colors.white : theme.colorScheme.primary),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

