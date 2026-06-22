// Halal Player - Image Viewer Screen
//
// Displays an image file with full AI safety analysis:
//  1. Show "Scanning..." while ImageAnalyzer runs
//  2. If blocked  → BlockedContentScreen
//  3. If blurred  → BackdropFilter blur with "View Anyway" option
//  4. If safe     → InteractiveViewer with zoom/pan
//  5. Result logged to contentLogsProvider

import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/image_analyzer.dart';
import '../../ai/ui/blur_block_widgets.dart';
import '../../providers.dart';

class ImageViewerScreen extends ConsumerStatefulWidget {
  const ImageViewerScreen({super.key, this.imagePath});

  final String? imagePath;

  @override
  ConsumerState<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends ConsumerState<ImageViewerScreen> {
  String? _path;
  ImageAnalysisResult? _analysisResult;
  bool _isAnalyzing = false;
  bool _userOverrode = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.imagePath != null) {
      _path = widget.imagePath;
      _analyzeImage(widget.imagePath!);
    }
  }

  // ── AI Analysis ──────────────────────────────────────────────────────────────

  Future<void> _analyzeImage(String path) async {
    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
      _error = null;
      _userOverrode = false;
    });

    try {
      // Initialise the AI gateway if needed
      final gateway = ref.read(aiGatewayProvider);
      if (!gateway.isReady) {
        await gateway.initialize();
      }

      final result = await ref.read(imageAnalyzerProvider).analyzeFile(path);

      if (!mounted) return;
      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });

      // Log the result
      final config = ref.read(appConfigProvider);
      if (config.enableLogging) {
        ref.read(contentLogsProvider.notifier).addLog(
              ContentLogEntry(
                timestamp: DateTime.now(),
                contentType: 'image',
                filePath: path,
                action: result.policyResult.action.name,
                score: result.policyResult.aggregatedScore,
                reason: result.policyResult.reason,
              ),
            );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        setState(() => _path = path);
        await _analyzeImage(path);
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ── No file selected ──────────────────────────────────────────────────────
    if (_path == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Image Viewer')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No image selected'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.folder_open),
                label: const Text('Open Image'),
              ),
            ],
          ),
        ),
      );
    }

    // ── Scanning ─────────────────────────────────────────────────────────────
    if (_isAnalyzing) return _buildScanningScreen();

    // ── Error ─────────────────────────────────────────────────────────────────
    if (_error != null) return _buildErrorScreen();

    final result = _analysisResult;

    // ── Blocked ───────────────────────────────────────────────────────────────
    if (result != null && result.shouldBlock && !_userOverrode) {
      return BlockedContentScreen(
        reason: result.policyResult.reason,
        confidenceScore: result.policyResult.aggregatedScore,
        onGoBack: () => setState(() {
          _path = null;
          _analysisResult = null;
        }),
      );
    }

    // ── Blurred or safe — show the image ────────────────────────────────────
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          _path!.split(r'\').last.split('/').last,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // AI result badge
          if (result != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AIStatusIndicator(isSafe: result.isSafe),
            ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Open Another Image',
            onPressed: _pickImage,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Actual image with zoom/pan
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 5.0,
            child: Center(
              child: Image.file(
                File(_path!),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image,
                      size: 64, color: Colors.grey),
                ),
              ),
            ),
          ),

          // Blur overlay for flagged-but-not-blocked content
          if (result != null && result.shouldBlur && !_userOverrode)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: BlurOverlay(
                isBlurred: true,
                warningMessage: result.policyResult.reason,
                onShowContent: () =>
                    setState(() => _userOverrode = true),
                child: const SizedBox.expand(),
              ),
            ),
        ],
      ),
    );
  }

  // ── Scanning screen ──────────────────────────────────────────────────────────

  Widget _buildScanningScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(seconds: 1),
                builder: (_, v, child) => Transform.rotate(
                  angle: v * 6.28,
                  child: child,
                ),
                child: Icon(Icons.security, size: 48,
                    color: Colors.green.shade400),
              ),
              const SizedBox(height: 24),
              Text(
                'Scanning Image',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'AI is analysing this image for inappropriate content',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 24),
              const LinearProgressIndicator(color: Colors.green),
              const SizedBox(height: 8),
              Text(
                _path!.split(r'\').last.split('/').last,
                style: const TextStyle(
                    color: Colors.green, fontSize: 12,
                    fontFamily: 'monospace'),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Error screen ─────────────────────────────────────────────────────────────

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Failed to load image:\n$_error',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() {
                _path = null;
                _error = null;
              }),
              child: const Text('Try Another'),
            ),
          ],
        ),
      ),
    );
  }
}
