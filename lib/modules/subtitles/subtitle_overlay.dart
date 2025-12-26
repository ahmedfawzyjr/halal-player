// Halal Player - Subtitle Overlay
//
// Overlay widget to display subtitles on video

import 'package:flutter/material.dart';
import 'subtitle_model.dart';

/// Subtitle overlay widget
class SubtitleOverlay extends StatelessWidget {
  const SubtitleOverlay({
    super.key,
    required this.entry,
    this.style = const SubtitleStyle(),
  });

  final SubtitleEntry? entry;
  final SubtitleStyle style;

  @override
  Widget build(BuildContext context) {
    if (entry == null || entry!.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: style.position == SubtitlePosition.bottom ? 50 : null,
      top: style.position == SubtitlePosition.top ? 50 : null,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            entry!.text,
            textAlign: TextAlign.center,
            style: style.toTextStyle(),
          ),
        ),
      ),
    );
  }
}

/// Subtitle controller widget with current position
class SubtitleView extends StatelessWidget {
  const SubtitleView({
    super.key,
    required this.track,
    required this.position,
    this.style = const SubtitleStyle(),
  });

  final SubtitleTrack? track;
  final Duration position;
  final SubtitleStyle style;

  @override
  Widget build(BuildContext context) {
    if (track == null || track!.isEmpty) {
      return const SizedBox.shrink();
    }

    final activeEntry = track!.getActiveEntry(position);
    
    return SubtitleOverlay(
      entry: activeEntry,
      style: style,
    );
  }
}

/// Subtitle settings panel widget
class SubtitleSettingsPanel extends StatelessWidget {
  const SubtitleSettingsPanel({
    super.key,
    required this.style,
    required this.onStyleChanged,
    this.availableTracks = const [],
    this.selectedTrackIndex,
    this.onTrackChanged,
  });

  final SubtitleStyle style;
  final ValueChanged<SubtitleStyle> onStyleChanged;
  final List<SubtitleTrack> availableTracks;
  final int? selectedTrackIndex;
  final ValueChanged<int?>? onTrackChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtitle Settings',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(),
          
          // Track selection
          if (availableTracks.isNotEmpty) ...[
            const Text('Track'),
            const SizedBox(height: 8),
            DropdownButton<int?>(
              isExpanded: true,
              value: selectedTrackIndex,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Off'),
                ),
                ...availableTracks.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value.title ?? 'Track ${entry.key + 1}'),
                  );
                }),
              ],
              onChanged: onTrackChanged,
            ),
            const SizedBox(height: 16),
          ],
          
          // Font size
          Row(
            children: [
              const Text('Font Size'),
              Expanded(
                child: Slider(
                  value: style.fontSize,
                  min: 12,
                  max: 40,
                  onChanged: (value) {
                    onStyleChanged(style.copyWith(fontSize: value));
                  },
                ),
              ),
              Text('${style.fontSize.round()}'),
            ],
          ),
          
          // Position
          Row(
            children: [
              const Text('Position'),
              const SizedBox(width: 16),
              SegmentedButton<SubtitlePosition>(
                segments: const [
                  ButtonSegment(
                    value: SubtitlePosition.top,
                    icon: Icon(Icons.vertical_align_top),
                  ),
                  ButtonSegment(
                    value: SubtitlePosition.center,
                    icon: Icon(Icons.vertical_align_center),
                  ),
                  ButtonSegment(
                    value: SubtitlePosition.bottom,
                    icon: Icon(Icons.vertical_align_bottom),
                  ),
                ],
                selected: {style.position},
                onSelectionChanged: (Set<SubtitlePosition> selected) {
                  onStyleChanged(style.copyWith(position: selected.first));
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Color options
          Row(
            children: [
              const Text('Font Color'),
              const SizedBox(width: 16),
              ...[ Colors.white, Colors.yellow, Colors.cyan, Colors.lime ].map((color) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => onStyleChanged(style.copyWith(fontColor: color)),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: style.fontColor == color 
                              ? Colors.blue 
                              : Colors.grey,
                          width: style.fontColor == color ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

/// Preview widget showing subtitle text
class SubtitlePreview extends StatelessWidget {
  const SubtitlePreview({
    super.key,
    required this.style,
  });

  final SubtitleStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          SubtitleOverlay(
            entry: SubtitleEntry(
              index: 1,
              start: Duration.zero,
              end: const Duration(seconds: 5),
              text: 'Preview subtitle text\nسطر نص الترجمة',
            ),
            style: style,
          ),
        ],
      ),
    );
  }
}
