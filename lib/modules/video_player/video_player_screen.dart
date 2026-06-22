// Halal Player - Video Player Screen
//
// Video playback with:
//  • Real AI content filtering (frame-by-frame via FFmpeg + Python AI)
//  • Real BackdropFilter blur for flagged content
//  • Subtitle overlay (auto-loaded from local file or OpenSubtitles)
//  • Full keyboard shortcuts (Space, F, J/L, M, arrows)
//  • Auto-hide controls after 3 seconds of inactivity
//  • Content log entries written to contentLogsProvider

import 'dart:async';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart' hide SubtitleTrack;
import 'package:media_kit_video/media_kit_video.dart' hide SubtitleView;

import '../../ai/ui/blur_block_widgets.dart';
import '../../core/keyboard_shortcuts.dart';
import '../../modules/subtitles/subtitle_model.dart';
import '../../modules/subtitles/subtitle_overlay.dart';
import '../../modules/subtitles/subtitle_parser.dart';
import '../../modules/subtitles/subtitle_provider.dart';
import '../../providers.dart';
import 'frame_extractor.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  const VideoPlayerScreen({super.key, this.initialPath});

  final String? initialPath;

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  // ── Media Kit ────────────────────────────────────────────────────────────────
  late final Player _player;
  late final VideoController _controller;

  // ── Playback state ───────────────────────────────────────────────────────────
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _showControls = true;
  bool _isFullscreen = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  String? _currentPath;

  // ── AI Filtering ─────────────────────────────────────────────────────────────
  bool _isAnalyzingAI = false;
  bool _isBlurred = false;
  bool _userOverrode = false; // user pressed "View Anyway"
  String? _warningMessage;
  StreamSubscription? _aiSubscription;

  // ── Controls auto-hide ───────────────────────────────────────────────────────
  Timer? _hideControlsTimer;

  // ── Subtitles ────────────────────────────────────────────────────────────────
  SubtitleTrack? _currentSubtitle;
  bool _subtitlesEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  // ── Player init ──────────────────────────────────────────────────────────────

  Future<void> _initializePlayer() async {
    _player = Player();
    _controller = VideoController(_player);

    _player.stream.playing.listen((v) {
      if (mounted) setState(() => _isPlaying = v);
      if (v) {
        ref.read(frameAnalyzerProvider).resume();
        _startHideTimer();
      } else {
        ref.read(frameAnalyzerProvider).pause();
      }
    });
    _player.stream.position
        .listen((v) { if (mounted) setState(() => _position = v); });
    _player.stream.duration
        .listen((v) { if (mounted) setState(() => _duration = v); });
    _player.stream.buffering
        .listen((v) { if (mounted) setState(() => _isBuffering = v); });
    _player.stream.volume
        .listen((v) { if (mounted) setState(() => _volume = v / 100); });

    setState(() => _isInitialized = true);

    if (widget.initialPath != null) {
      await _openFile(widget.initialPath!);
    }
  }

  // ── Open file ────────────────────────────────────────────────────────────────

  Future<void> _openFile(String path) async {
    setState(() {
      _currentPath = path;
      _isBlurred = false;
      _userOverrode = false;
      _warningMessage = null;
      _currentSubtitle = null;
      _isAnalyzingAI = true;
    });

    await _player.open(Media(path));
    _setupFrameAnalyzer(path);

    // Load subtitles in the background
    _loadSubtitles(path);
  }

  // ── AI Frame Analysis ────────────────────────────────────────────────────────

  void _setupFrameAnalyzer(String videoPath) {
    final analyzer = ref.read(frameAnalyzerProvider);

    // Register the frame-callback: extract a frame at the current position
    analyzer.setFrameCallback(() async {
      if (_currentPath == null || !_isPlaying) return null;
      return VideoFrameExtractor.extractFrame(_currentPath!, _position);
    });

    // Listen for results
    _aiSubscription?.cancel();
    _aiSubscription = analyzer.resultStream.listen((result) {
      if (!mounted) return;

      final config = ref.read(appConfigProvider);

      setState(() {
        _isAnalyzingAI = false;

        if (!_userOverrode) {
          if (result.shouldBlock) {
            _isBlurred = true;
            _warningMessage = result.policyResult.reason;
            if (config.autoSkipFlagged) {
              // Skip 30 seconds ahead
              _player.seek(_position + const Duration(seconds: 30));
            }
          } else if (result.shouldBlur && config.enableBlurEffect) {
            _isBlurred = true;
            _warningMessage = result.policyResult.reason;
          } else {
            _isBlurred = false;
            _warningMessage = null;
          }
        }
      });

      // Log if enabled
      if (config.enableLogging &&
          (result.shouldBlur || result.shouldBlock)) {
        ref.read(contentLogsProvider.notifier).addLog(
              ContentLogEntry(
                timestamp: DateTime.now(),
                contentType: 'video',
                filePath: videoPath,
                action: result.policyResult.action.name,
                score: result.policyResult.aggregatedScore,
                reason: result.policyResult.reason,
              ),
            );
      }
    });

    analyzer.start();
  }

  // ── Subtitle loading ─────────────────────────────────────────────────────────

  Future<void> _loadSubtitles(String videoPath) async {
    final track = await loadSubtitleForVideo(ref, videoPath);
    if (mounted) setState(() => _currentSubtitle = track);
  }

  Future<void> _pickSubtitleFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt', 'ass', 'ssa'],
    );
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        final track = await SubtitleParser.parseFile(path);
        if (mounted) setState(() => _currentSubtitle = track);
      }
    }
  }

  // ── Playback controls ────────────────────────────────────────────────────────

  void _seekBy(Duration delta) {
    final target = _position + delta;
    if (target < Duration.zero) {
      _player.seek(Duration.zero);
    } else if (target > _duration && _duration > Duration.zero) {
      _player.seek(_duration);
    } else {
      _player.seek(target);
    }
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  // ── Controls auto-hide ───────────────────────────────────────────────────────

  void _startHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) setState(() => _showControls = false);
    });
  }

  void _showControlsTemporarily() {
    if (!_showControls) setState(() => _showControls = true);
    if (_isPlaying) _startHideTimer();
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _aiSubscription?.cancel();
    final analyzer = ref.read(frameAnalyzerProvider);
    analyzer.setFrameCallback(null);
    analyzer.stop();
    _player.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return KeyboardShortcutsHandler(
      onPlayPause: () => _isPlaying ? _player.pause() : _player.play(),
      onSeekForward: () => _seekBy(const Duration(seconds: 10)),
      onSeekBackward: () => _seekBy(const Duration(seconds: -10)),
      onVolumeUp: () => _player.setVolume((_volume * 100 + 10).clamp(0, 100)),
      onVolumeDown: () => _player.setVolume((_volume * 100 - 10).clamp(0, 100)),
      onMute: () => _player.setVolume(_volume > 0 ? 0 : 100),
      onFullscreen: _toggleFullscreen,
      onOpenFile: () async {
        final result = await FilePicker.platform
            .pickFiles(type: FileType.video);
        if (result != null && result.files.isNotEmpty) {
          final path = result.files.first.path;
          if (path != null) await _openFile(path);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: MouseRegion(
          onHover: (_) => _showControlsTemporarily(),
          child: GestureDetector(
            onTap: () {
              if (_showControls) {
                setState(() => _showControls = false);
                _hideControlsTimer?.cancel();
              } else {
                _showControlsTemporarily();
              }
            },
            onDoubleTap: _toggleFullscreen,
            child: Stack(
              children: [
                // 1. Video
                Center(
                  child: _isBlurred && !_userOverrode
                      ? _buildBlurredVideo()
                      : Video(
                          controller: _controller,
                          fill: Colors.black,
                        ),
                ),

                // 2. Buffering indicator
                if (_isBuffering)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),

                // 3. Subtitle overlay
                if (_currentSubtitle != null && _subtitlesEnabled)
                  Positioned(
                    bottom: 90,
                    left: 16,
                    right: 16,
                    child: SubtitleView(
                      track: _currentSubtitle!,
                      position: _position,
                    ),
                  ),

                // 4. Controls overlay
                if (_showControls) _buildControlsOverlay(),

                // 5. Warning banner
                if (_warningMessage != null && !_userOverrode)
                  _buildWarningBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Blurred video ────────────────────────────────────────────────────────────

  Widget _buildBlurredVideo() {
    return Stack(
      children: [
        // Real video behind the blur
        Video(controller: _controller, fill: Colors.black),
        // Real BackdropFilter blur
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(color: Colors.black.withValues(alpha: 0.55)),
        ),
        // Warning card
        Center(
          child: BlurOverlay(
            isBlurred: true,
            warningMessage: _warningMessage,
            onShowContent: () => setState(() {
              _userOverrode = true;
              _isBlurred = false;
            }),
            child: const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  // ── Warning banner ───────────────────────────────────────────────────────────

  Widget _buildWarningBanner() {
    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _warningMessage ?? 'Content flagged by AI',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => setState(() => _warningMessage = null),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Controls overlay ─────────────────────────────────────────────────────────

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black54,
            Colors.transparent,
            Colors.transparent,
            Colors.black54,
          ],
          stops: const [0, 0.2, 0.8, 1],
        ),
      ),
      child: Column(
        children: [
          _buildTopBar(),
          const Spacer(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _currentPath?.split(r'\').last.split('/').last ?? 'Video Player',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // AI analyzing indicator
          if (_isAnalyzingAI)
            const AIStatusIndicator(isAnalyzing: true)
          else
            AIStatusIndicator(isSafe: !_isBlurred),
          const SizedBox(width: 8),
          // Subtitles toggle
          IconButton(
            icon: Icon(
              _subtitlesEnabled ? Icons.subtitles : Icons.subtitles_off,
              color: _subtitlesEnabled ? Colors.green : Colors.white54,
            ),
            tooltip: 'Toggle Subtitles',
            onPressed: () =>
                setState(() => _subtitlesEnabled = !_subtitlesEnabled),
          ),
          // Load subtitle file
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.white70),
            tooltip: 'Load Subtitle File',
            onPressed: _pickSubtitleFile,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress row
          Row(
            children: [
              Text(
                _formatDuration(_position),
                style:
                    const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: Colors.green,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.green,
                  ),
                  child: Slider(
                    value: _duration.inMilliseconds > 0
                        ? (_position.inMilliseconds /
                                _duration.inMilliseconds)
                            .clamp(0.0, 1.0)
                        : 0,
                    onChanged: (value) {
                      final pos = Duration(
                        milliseconds:
                            (value * _duration.inMilliseconds).round(),
                      );
                      _player.seek(pos);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(_duration),
                style:
                    const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Volume
              IconButton(
                icon: Icon(
                  _volume > 0 ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                ),
                onPressed: () =>
                    _player.setVolume(_volume > 0 ? 0 : 100),
              ),
              SizedBox(
                width: 90,
                child: Slider(
                  value: _volume.clamp(0, 1),
                  onChanged: (v) =>
                      _player.setVolume((v * 100).round().toDouble()),
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                ),
              ),
              const SizedBox(width: 16),
              // Rewind
              IconButton(
                icon: const Icon(Icons.replay_10,
                    color: Colors.white, size: 30),
                onPressed: () => _seekBy(const Duration(seconds: -10)),
              ),
              // Play/Pause
              IconButton(
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 52,
                ),
                onPressed: () =>
                    _isPlaying ? _player.pause() : _player.play(),
              ),
              // Forward
              IconButton(
                icon: const Icon(Icons.forward_10,
                    color: Colors.white, size: 30),
                onPressed: () => _seekBy(const Duration(seconds: 10)),
              ),
              const SizedBox(width: 16),
              // Speed
              PopupMenuButton<double>(
                icon: const Icon(Icons.speed, color: Colors.white),
                onSelected: _player.setRate,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0.5, child: Text('0.5×')),
                  const PopupMenuItem(value: 0.75, child: Text('0.75×')),
                  const PopupMenuItem(value: 1.0, child: Text('1.0×')),
                  const PopupMenuItem(value: 1.25, child: Text('1.25×')),
                  const PopupMenuItem(value: 1.5, child: Text('1.5×')),
                  const PopupMenuItem(value: 2.0, child: Text('2.0×')),
                ],
              ),
              // Fullscreen
              IconButton(
                icon: Icon(
                  _isFullscreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: _toggleFullscreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
