// Halal Player - App Entry Point
// 
// Privacy-first media player with AI content filtering

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'l10n/app_localizations.dart';

import 'ui/home/home_screen.dart';
import 'ui/settings/settings_screen.dart';
import 'ui/logs/logs_screen.dart';
import 'modules/video_player/video_player_screen.dart';
import 'modules/audio_player/audio_player_screen.dart';
import 'modules/image_viewer/image_viewer_screen.dart';
import 'core/theme.dart';
import 'core/language_provider.dart';
import 'providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for storage
  await Hive.initFlutter();
  
  // Initialize MediaKit
  MediaKit.ensureInitialized();

  // Initialize window manager
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Halal Player',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: HalalPlayerApp()));
}

class HalalPlayerApp extends ConsumerWidget {
  const HalalPlayerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(languageProvider);
    
    return MaterialApp(
      title: 'Halal Player',
      debugShowCheckedModeBanner: false,
      
      // Theming
      themeMode: themeMode,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      
      // Localization
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      home: const MainNavigationView(),
    );
  }
}

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView>
    with WindowListener {
  int _selectedIndex = 0;
  
  // Currently opened media file paths
  String? _currentVideoPath;
  String? _currentAudioPath;
  String? _currentImagePath;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return _currentVideoPath != null
            ? VideoPlayerScreen(initialPath: _currentVideoPath)
            : _buildOpenFilePrompt('video', FileType.video);
      case 2:
        return _currentAudioPath != null
            ? AudioPlayerScreen(initialPath: _currentAudioPath)
            : _buildOpenFilePrompt('audio', FileType.audio);
      case 3:
        return _currentImagePath != null
            ? ImageViewerScreen(imagePath: _currentImagePath)
            : _buildOpenFilePrompt('image', FileType.image);
      case 4:
        return const LogsScreen();
      case 5:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildOpenFilePrompt(String type, FileType fileType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'video' ? Icons.videocam 
                : type == 'audio' ? Icons.audiotrack 
                : Icons.image,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 24),
          Text(
            'No $type file opened',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _pickFile(fileType),
            icon: const Icon(Icons.folder_open),
            label: Text('Open $type'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile(FileType type) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        setState(() {
          switch (type) {
            case FileType.video:
              _currentVideoPath = path;
              _selectedIndex = 1;
              break;
            case FileType.audio:
              _currentAudioPath = path;
              _selectedIndex = 2;
              break;
            case FileType.image:
              _currentImagePath = path;
              _selectedIndex = 3;
              break;
            default:
              break;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: GestureDetector(
          onPanStart: (_) => windowManager.startDragging(),
          child: Row(
            children: [
              Icon(Icons.play_circle_filled, color: Colors.green[400]),
              const SizedBox(width: 8),
              const Text(
                'Halal Player',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.minimize),
            onPressed: () => windowManager.minimize(),
          ),
          IconButton(
            icon: const Icon(Icons.crop_square),
            onPressed: () async {
              if (await windowManager.isMaximized()) {
                windowManager.unmaximize();
              } else {
                windowManager.maximize();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => windowManager.close(),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            backgroundColor: const Color(0xFF2A2A2A),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.videocam_outlined),
                selectedIcon: Icon(Icons.videocam),
                label: Text('Video'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.audiotrack_outlined),
                selectedIcon: Icon(Icons.audiotrack),
                label: Text('Audio'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.image_outlined),
                selectedIcon: Icon(Icons.image),
                label: Text('Images'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: Text('Logs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _getScreen(_selectedIndex),
          ),
        ],
      ),
    );
  }
}
