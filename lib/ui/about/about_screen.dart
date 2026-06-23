// Halal Player - About Screen
//
// Application information and credits

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String version = '1.0.4';
  static const String buildNumber = '2025.12.26';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutHalalPlayer),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/img/logo-icon.png',
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.play_circle,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // App Name
            Text(
              'Halal Player',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Version
            Text(
              '${l10n.version} $version (Build $buildNumber)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, 
                          color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          l10n.about,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.aboutDesc),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Features
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, 
                          color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          l10n.features,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureRow(Icons.shield, l10n.aiContentFiltering),
                    _buildFeatureRow(Icons.videocam, l10n.videoPlayer),
                    _buildFeatureRow(Icons.audiotrack, l10n.audioPlayer),
                    _buildFeatureRow(Icons.image, l10n.imageViewer),
                    _buildFeatureRow(Icons.subtitles, l10n.autoSubtitles),
                    _buildFeatureRow(Icons.language, l10n.fifteenLanguages),
                    _buildFeatureRow(Icons.wifi_off, l10n.oneHundredPercentOffline),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Developer
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.code, 
                          color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          l10n.developerRole,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: const Text('Ahmed Fawzy'),
                      subtitle: Text(l10n.developerRole),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Links
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.code),
                    title: Text(l10n.githubRepository),
                    subtitle: const Text('github.com/ahmedfawzyjr/Halal-Player'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      // Open GitHub
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.bug_report),
                    title: Text(l10n.reportIssue),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      // Open issues page
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Copyright
            Text(
              l10n.allRightsReserved,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.madeWithLove,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
