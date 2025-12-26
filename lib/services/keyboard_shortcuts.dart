// Halal Player - Keyboard Shortcuts
//
// Global keyboard shortcuts for media control

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard shortcut definitions
class KeyboardShortcuts {
  KeyboardShortcuts._();

  // Playback Controls
  static const playPause = SingleActivator(LogicalKeyboardKey.space);
  static const stop = SingleActivator(LogicalKeyboardKey.keyS, control: true);
  static const seekForward = SingleActivator(LogicalKeyboardKey.arrowRight);
  static const seekBackward = SingleActivator(LogicalKeyboardKey.arrowLeft);
  static const seekForwardLong = SingleActivator(LogicalKeyboardKey.arrowRight, shift: true);
  static const seekBackwardLong = SingleActivator(LogicalKeyboardKey.arrowLeft, shift: true);
  
  // Volume Controls
  static const volumeUp = SingleActivator(LogicalKeyboardKey.arrowUp);
  static const volumeDown = SingleActivator(LogicalKeyboardKey.arrowDown);
  static const mute = SingleActivator(LogicalKeyboardKey.keyM);
  
  // Display Controls
  static const fullscreen = SingleActivator(LogicalKeyboardKey.keyF);
  static const fullscreenAlt = SingleActivator(LogicalKeyboardKey.f11);
  static const escapeFullscreen = SingleActivator(LogicalKeyboardKey.escape);
  
  // Navigation
  static const home = SingleActivator(LogicalKeyboardKey.home);
  static const openFile = SingleActivator(LogicalKeyboardKey.keyO, control: true);
  
  // Subtitle Controls
  static const toggleSubtitles = SingleActivator(LogicalKeyboardKey.keyV);
  static const nextSubtitle = SingleActivator(LogicalKeyboardKey.keyJ);
  static const previousSubtitle = SingleActivator(LogicalKeyboardKey.keyK);
  
  // Window Controls
  static const minimize = SingleActivator(LogicalKeyboardKey.minus, control: true);
  static const quit = SingleActivator(LogicalKeyboardKey.keyQ, control: true);
}

/// Intent definitions
class PlayPauseIntent extends Intent {
  const PlayPauseIntent();
}

class SeekForwardIntent extends Intent {
  const SeekForwardIntent({this.seconds = 10});
  final int seconds;
}

class SeekBackwardIntent extends Intent {
  const SeekBackwardIntent({this.seconds = 10});
  final int seconds;
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

class FullscreenIntent extends Intent {
  const FullscreenIntent();
}

class ToggleSubtitlesIntent extends Intent {
  const ToggleSubtitlesIntent();
}

class OpenFileIntent extends Intent {
  const OpenFileIntent();
}

/// Keyboard shortcuts wrapper widget
class KeyboardShortcutsWrapper extends StatelessWidget {
  const KeyboardShortcutsWrapper({
    super.key,
    required this.child,
    this.onPlayPause,
    this.onSeekForward,
    this.onSeekBackward,
    this.onVolumeUp,
    this.onVolumeDown,
    this.onMute,
    this.onFullscreen,
    this.onToggleSubtitles,
    this.onOpenFile,
  });

  final Widget child;
  final VoidCallback? onPlayPause;
  final void Function(int seconds)? onSeekForward;
  final void Function(int seconds)? onSeekBackward;
  final VoidCallback? onVolumeUp;
  final VoidCallback? onVolumeDown;
  final VoidCallback? onMute;
  final VoidCallback? onFullscreen;
  final VoidCallback? onToggleSubtitles;
  final VoidCallback? onOpenFile;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        KeyboardShortcuts.playPause: const PlayPauseIntent(),
        KeyboardShortcuts.seekForward: const SeekForwardIntent(seconds: 10),
        KeyboardShortcuts.seekBackward: const SeekBackwardIntent(seconds: 10),
        KeyboardShortcuts.seekForwardLong: const SeekForwardIntent(seconds: 30),
        KeyboardShortcuts.seekBackwardLong: const SeekBackwardIntent(seconds: 30),
        KeyboardShortcuts.volumeUp: const VolumeUpIntent(),
        KeyboardShortcuts.volumeDown: const VolumeDownIntent(),
        KeyboardShortcuts.mute: const MuteIntent(),
        KeyboardShortcuts.fullscreen: const FullscreenIntent(),
        KeyboardShortcuts.fullscreenAlt: const FullscreenIntent(),
        KeyboardShortcuts.toggleSubtitles: const ToggleSubtitlesIntent(),
        KeyboardShortcuts.openFile: const OpenFileIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PlayPauseIntent: CallbackAction<PlayPauseIntent>(
            onInvoke: (_) => onPlayPause?.call(),
          ),
          SeekForwardIntent: CallbackAction<SeekForwardIntent>(
            onInvoke: (intent) => onSeekForward?.call(intent.seconds),
          ),
          SeekBackwardIntent: CallbackAction<SeekBackwardIntent>(
            onInvoke: (intent) => onSeekBackward?.call(intent.seconds),
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
          FullscreenIntent: CallbackAction<FullscreenIntent>(
            onInvoke: (_) => onFullscreen?.call(),
          ),
          ToggleSubtitlesIntent: CallbackAction<ToggleSubtitlesIntent>(
            onInvoke: (_) => onToggleSubtitles?.call(),
          ),
          OpenFileIntent: CallbackAction<OpenFileIntent>(
            onInvoke: (_) => onOpenFile?.call(),
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

/// Keyboard shortcuts help dialog
class KeyboardShortcutsDialog extends StatelessWidget {
  const KeyboardShortcutsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.keyboard),
          const SizedBox(width: 8),
          const Text('Keyboard Shortcuts'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('Playback', [
                _buildShortcut('Space', 'Play / Pause'),
                _buildShortcut('← →', 'Seek 10 seconds'),
                _buildShortcut('Shift + ← →', 'Seek 30 seconds'),
                _buildShortcut('Ctrl + S', 'Stop'),
              ]),
              const SizedBox(height: 16),
              _buildSection('Volume', [
                _buildShortcut('↑ ↓', 'Volume Up / Down'),
                _buildShortcut('M', 'Mute / Unmute'),
              ]),
              const SizedBox(height: 16),
              _buildSection('Display', [
                _buildShortcut('F / F11', 'Toggle Fullscreen'),
                _buildShortcut('Esc', 'Exit Fullscreen'),
              ]),
              const SizedBox(height: 16),
              _buildSection('Subtitles', [
                _buildShortcut('V', 'Toggle Subtitles'),
                _buildShortcut('J / K', 'Next / Previous Subtitle'),
              ]),
              const SizedBox(height: 16),
              _buildSection('Navigation', [
                _buildShortcut('Ctrl + O', 'Open File'),
                _buildShortcut('Ctrl + Q', 'Quit'),
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

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildShortcut(String key, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              key,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(action)),
        ],
      ),
    );
  }
}
