// Halal Player - Audio Player Screen
//
// Audio playback with waveform visualization

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key, this.initialPath});

  final String? initialPath;

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late final AudioPlayer _player;
  
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  LoopMode _loopMode = LoopMode.off;
  
  String? _currentTitle;
  String? _currentArtist;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _player = AudioPlayer();
    
    // Listen to player streams
    _player.playingStream.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });
    
    _player.positionStream.listen((position) {
      if (mounted) setState(() => _position = position);
    });
    
    _player.durationStream.listen((duration) {
      if (mounted && duration != null) setState(() => _duration = duration);
    });
    
    _player.volumeStream.listen((volume) {
      if (mounted) setState(() => _volume = volume);
    });
    
    _player.loopModeStream.listen((loopMode) {
      if (mounted) setState(() => _loopMode = loopMode);
    });
    
    _player.processingStateStream.listen((state) {
      if (mounted) {
        setState(() => _isLoading = state == ProcessingState.loading);
      }
    });
    
    setState(() => _isInitialized = true);
    
    // Open initial file if provided
    if (widget.initialPath != null) {
      await _openFile(widget.initialPath!);
    }
  }

  Future<void> _openFile(String path) async {
    setState(() {
      _isLoading = true;
      _currentTitle = path.split('/').last.split('\\').last;
      _currentArtist = 'Unknown Artist';
    });
    
    try {
      await _player.setFilePath(path);
      // TODO: Extract metadata (title, artist, album art)
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Audio Player'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield, color: Colors.green, size: 14),
                SizedBox(width: 4),
                Text(
                  'Protected',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Album art / Visualization area
          Expanded(
            flex: 3,
            child: _buildVisualizationArea(),
          ),
          
          // Track info
          _buildTrackInfo(),
          
          // Progress bar
          _buildProgressBar(),
          
          // Controls
          _buildControls(),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildVisualizationArea() {
    return Container(
      margin: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade900,
            Colors.green.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isPlaying ? Icons.music_note : Icons.audiotrack,
              size: 80,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator(color: Colors.white)
            else
              _buildWaveformPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveformPlaceholder() {
    // TODO: Implement actual waveform visualization
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(20, (index) {
        final height = _isPlaying
            ? 10.0 + (index % 3) * 15 + (index % 5) * 8
            : 10.0;
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + index * 20),
          width: 4,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildTrackInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            _currentTitle ?? 'No track loaded',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _currentArtist ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: Colors.green,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.green,
            ),
            child: Slider(
              value: _duration.inMilliseconds > 0
                  ? _position.inMilliseconds / _duration.inMilliseconds
                  : 0,
              onChanged: (value) {
                final position = Duration(
                  milliseconds: (value * _duration.inMilliseconds).round(),
                );
                _player.seek(position);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  _formatDuration(_duration),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle (placeholder)
          IconButton(
            icon: const Icon(Icons.shuffle, color: Colors.grey),
            onPressed: () {
              // TODO: Implement shuffle
            },
          ),
          
          // Previous
          IconButton(
            icon: const Icon(Icons.skip_previous, size: 40),
            onPressed: () {
              _player.seek(Duration.zero);
            },
          ),
          
          // Play/Pause
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                size: 40,
                color: Colors.white,
              ),
              onPressed: () {
                _isPlaying ? _player.pause() : _player.play();
              },
            ),
          ),
          
          // Next
          IconButton(
            icon: const Icon(Icons.skip_next, size: 40),
            onPressed: () {
              // TODO: Implement next track
            },
          ),
          
          // Loop mode
          IconButton(
            icon: Icon(
              _loopMode == LoopMode.one
                  ? Icons.repeat_one
                  : Icons.repeat,
              color: _loopMode != LoopMode.off ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              final modes = [LoopMode.off, LoopMode.one, LoopMode.all];
              final nextIndex = (modes.indexOf(_loopMode) + 1) % modes.length;
              _player.setLoopMode(modes[nextIndex]);
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
