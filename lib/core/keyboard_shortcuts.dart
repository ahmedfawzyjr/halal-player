// Halal Player - Keyboard Shortcuts
//
// Global keyboard shortcuts for the application

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard shortcuts handler widget
class KeyboardShortcutsHandler extends StatelessWidget {
  const KeyboardShortcutsHandler({
    super.key,
    required this.child,
    this.onPlayPause,
    this.onVolumeUp,
    this.onVolumeDown,
    this.onMute,
    this.onFullscreen,
    this.onSeekForward,
    this.onSeekBackward,
    this.onOpenFile,
    this.onSettings,
    this.onHome,
  });

  final Widget child;
  final VoidCallback? onPlayPause;
  final VoidCallback? onVolumeUp;
  final VoidCallback? onVolumeDown;
  final VoidCallback? onMute;
  final VoidCallback? onFullscreen;
  final VoidCallback? onSeekForward;
  final VoidCallback? onSeekBackward;
  final VoidCallback? onOpenFile;
  final VoidCallback? onSettings;
  final VoidCallback? onHome;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        // Playback
        const SingleActivator(LogicalKeyboardKey.space): const PlayPauseIntent(),
        const SingleActivator(LogicalKeyboardKey.keyK): const PlayPauseIntent(),
        
        // Volume
        const SingleActivator(LogicalKeyboardKey.arrowUp): const VolumeUpIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowDown): const VolumeDownIntent(),
        const SingleActivator(LogicalKeyboardKey.keyM): const MuteIntent(),
        
        // Seeking
        const SingleActivator(LogicalKeyboardKey.arrowRight): const SeekForwardIntent(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): const SeekBackwardIntent(),
        const SingleActivator(LogicalKeyboardKey.keyL): const SeekForwardIntent(),
        const SingleActivator(LogicalKeyboardKey.keyJ): const SeekBackwardIntent(),
        
        // Fullscreen
        const SingleActivator(LogicalKeyboardKey.keyF): const FullscreenIntent(),
        const SingleActivator(LogicalKeyboardKey.escape): const ExitFullscreenIntent(),
        
        // File operations
        const SingleActivator(LogicalKeyboardKey.keyO, control: true): const OpenFileIntent(),
        
        // Navigation
        const SingleActivator(LogicalKeyboardKey.keyH, control: true): const HomeIntent(),
        const SingleActivator(LogicalKeyboardKey.comma, control: true): const SettingsIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PlayPauseIntent: CallbackAction<PlayPauseIntent>(
            onInvoke: (_) => onPlayPause?.call(),
          ),
          VolumeUpIntent: CallbackAction<VolumeUpIntent>(
            onInvoke: (_) => onVolumeUp?.call(),
          ),
          VolumeDownIntent: CallbackAction<VolumeDownIntent>(
            onInvoke: (_) => onVolumeDown?.call(),
          ),
          MuteIntent: CallbackAction<MuteIntent>(
            onInvoke: (_) => onMute?.call(),
          ),
          SeekForwardIntent: CallbackAction<SeekForwardIntent>(
            onInvoke: (_) => onSeekForward?.call(),
          ),
          SeekBackwardIntent: CallbackAction<SeekBackwardIntent>(
            onInvoke: (_) => onSeekBackward?.call(),
          ),
          FullscreenIntent: CallbackAction<FullscreenIntent>(
            onInvoke: (_) => onFullscreen?.call(),
          ),
          ExitFullscreenIntent: CallbackAction<ExitFullscreenIntent>(
            onInvoke: (_) => onFullscreen?.call(),
          ),
          OpenFileIntent: CallbackAction<OpenFileIntent>(
            onInvoke: (_) => onOpenFile?.call(),
          ),
          HomeIntent: CallbackAction<HomeIntent>(
            onInvoke: (_) => onHome?.call(),
          ),
          SettingsIntent: CallbackAction<SettingsIntent>(
            onInvoke: (_) => onSettings?.call(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

// Intents
class PlayPauseIntent extends Intent {
  const PlayPauseIntent();
}

class VolumeUpIntent extends Intent {
  const VolumeUpIntent();
}

class VolumeDownIntent extends Intent {
  const VolumeDownIntent();
}

class MuteIntent extends Intent {
  const MuteIntent();
}

class SeekForwardIntent extends Intent {
  const SeekForwardIntent();
}

class SeekBackwardIntent extends Intent {
  const SeekBackwardIntent();
}

class FullscreenIntent extends Intent {
  const FullscreenIntent();
}

class ExitFullscreenIntent extends Intent {
  const ExitFullscreenIntent();
}

class OpenFileIntent extends Intent {
  const OpenFileIntent();
}

class HomeIntent extends Intent {
  const HomeIntent();
}

class SettingsIntent extends Intent {
  const SettingsIntent();
}

/// Keyboard shortcuts help dialog
class KeyboardShortcutsDialog extends StatelessWidget {
  const KeyboardShortcutsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.keyboard),
          SizedBox(width: 8),
          Text('Keyboard Shortcuts'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSection('Playback', [
                ('Space / K', 'Play/Pause'),
                ('F', 'Toggle Fullscreen'),
                ('Esc', 'Exit Fullscreen'),
              ]),
              const SizedBox(height: 16),
              _buildSection('Seeking', [
                ('→ / L', 'Forward 10 seconds'),
                ('← / J', 'Backward 10 seconds'),
              ]),
              const SizedBox(height: 16),
              _buildSection('Volume', [
                ('↑', 'Volume Up'),
                ('↓', 'Volume Down'),
                ('M', 'Mute/Unmute'),
              ]),
              const SizedBox(height: 16),
              _buildSection('Navigation', [
                ('Ctrl+O', 'Open File'),
                ('Ctrl+H', 'Go Home'),
                ('Ctrl+,', 'Settings'),
              ]),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<(String, String)> shortcuts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...shortcuts.map((s) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Text(
                  s.$1,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(width: 16),
              Text(s.$2),
            ],
          ),
        )),
      ],
    );
  }
}
