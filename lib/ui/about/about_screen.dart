// Halal Player - About Screen
//
// Application information and credits

import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String version = '1.0.4';
  static const String buildNumber = '2025.12.26';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Halal Player'),
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
                errorBuilder: (_, __, ___) => Icon(
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
              'Version $version (Build $buildNumber)',
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
                          'About',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Halal Player is a privacy-first media player with AI-powered '
                      'content filtering for Islamic compliance. All processing happens '
                      'locally on your device - your media never leaves your computer.',
                    ),
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
                          'Features',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureRow(Icons.shield, 'AI Content Filtering'),
                    _buildFeatureRow(Icons.videocam, 'Video Player'),
                    _buildFeatureRow(Icons.audiotrack, 'Audio Player'),
                    _buildFeatureRow(Icons.image, 'Image Viewer'),
                    _buildFeatureRow(Icons.subtitles, 'Auto Subtitles'),
                    _buildFeatureRow(Icons.language, '15 Languages'),
                    _buildFeatureRow(Icons.wifi_off, '100% Offline'),
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
                          'Developer',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text('Ahmed Fawzy'),
                      subtitle: Text('Developer'),
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
                    title: const Text('GitHub Repository'),
                    subtitle: const Text('github.com/ahmedfawzyjr/Halal-Player'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      // Open GitHub
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.bug_report),
                    title: const Text('Report Issue'),
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
              '© 2025 Ahmed Fawzy. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Made with ❤️ for the Muslim community',
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
