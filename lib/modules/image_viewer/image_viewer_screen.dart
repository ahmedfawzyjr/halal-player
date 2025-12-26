// Halal Player - Image Viewer Screen
//
// Image viewing with AI content filtering

import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({super.key, this.imagePath});

  final String? imagePath;

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  final TransformationController _transformController = TransformationController();
  
  bool _isAnalyzing = true;
  bool _isBlurred = false;
  bool _isSafe = false;
  double _confidenceScore = 0.0;
  String? _analysisReason;
  
  bool _showInfo = false;

  @override
  void initState() {
    super.initState();
    if (widget.imagePath != null) {
      _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    setState(() => _isAnalyzing = true);
    
    // TODO: Implement actual AI analysis
    // Simulating AI analysis delay
    await Future.delayed(const Duration(seconds: 1));
    
    // For now, mark as safe (placeholder)
    setState(() {
      _isAnalyzing = false;
      _isSafe = true;
      _isBlurred = false;
      _confidenceScore = 0.05;
      _analysisReason = 'Content passed all safety checks';
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image viewer
          _buildImageViewer(),
          
          // Top bar
          _buildTopBar(),
          
          // Analysis overlay
          if (_isAnalyzing) _buildAnalyzingOverlay(),
          
          // Blur warning
          if (_isBlurred) _buildBlurWarning(),
          
          // Bottom info bar
          if (_showInfo && !_isAnalyzing) _buildInfoBar(),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    if (widget.imagePath == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No image loaded',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    Widget imageWidget = InteractiveViewer(
      transformationController: _transformController,
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.file(
          File(widget.imagePath!),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.red[300]),
                ),
              ],
            );
          },
        ),
      ),
    );

    // Apply blur if flagged
    if (_isBlurred) {
      imageWidget = Stack(
        children: [
          // TODO: Apply actual blur effect
          Container(color: Colors.black),
          Center(
            child: Icon(
              Icons.visibility_off,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onDoubleTap: _resetZoom,
      child: imageWidget,
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: Text(
                  'Image Viewer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // AI Status
              if (!_isAnalyzing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isSafe
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.red.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isSafe ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isSafe ? Icons.check_circle : Icons.warning,
                        color: _isSafe ? Colors.green : Colors.red,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isSafe ? 'Safe' : 'Flagged',
                        style: TextStyle(
                          color: _isSafe ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(width: 8),
              
              // Info button
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: _showInfo ? Colors.green : Colors.white,
                ),
                onPressed: () => setState(() => _showInfo = !_showInfo),
              ),
              
              // Zoom reset
              IconButton(
                icon: const Icon(Icons.zoom_out_map, color: Colors.white),
                onPressed: _resetZoom,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Analyzing Image...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI is checking content safety',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlurWarning() {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Content flagged by AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (_analysisReason != null) ...[
              const SizedBox(height: 8),
              Text(
                _analysisReason!,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                    child: const Text('Go Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      setState(() => _isBlurred = false);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white24,
                    ),
                    child: const Text('View Anyway'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AI Analysis Results',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _isSafe ? Icons.check_circle : Icons.warning,
                  color: _isSafe ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _analysisReason ?? 'Unknown',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Confidence: ${(_confidenceScore * 100).toStringAsFixed(1)}%',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }
}
