// Halal Player - Translation Screen
//
// UI for translating subtitle files:
//  • Source / target language pickers
//  • Load an SRT/VTT/ASS file to translate
//  • Shows progress while translating entry-by-entry
//  • Previews translated output in a scrollable list
//  • Save translated file button

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/subtitles/subtitle_model.dart';
import '../../modules/subtitles/subtitle_parser.dart';
import '../../modules/translation/translation_service.dart';

/// Translation engine selector
enum TranslationEngine { argos, libre }

class TranslationScreen extends ConsumerStatefulWidget {
  const TranslationScreen({super.key});

  @override
  ConsumerState<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends ConsumerState<TranslationScreen> {
  // ── Engine ───────────────────────────────────────────────────────────────────
  TranslationEngine _engine = TranslationEngine.libre;
  TranslationService? _service;

  // ── Language selection ───────────────────────────────────────────────────────
  String _sourceLang = 'auto';
  String _targetLang = 'ar';

  // ── File state ───────────────────────────────────────────────────────────────
  String? _inputPath;
  SubtitleTrack? _originalTrack;
  SubtitleTrack? _translatedTrack;

  // ── Progress ─────────────────────────────────────────────────────────────────
  bool _isTranslating = false;
  int _progressCurrent = 0;
  int _progressTotal = 0;
  String? _savedPath;
  String? _error;

  // ── Engine availability ───────────────────────────────────────────────────────
  bool _argosAvailable = false;
  bool _libreAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkEngineAvailability();
  }

  Future<void> _checkEngineAvailability() async {
    final argosAvail = await ArgosTranslateService().isAvailable();
    final libreAvail =
        await LibreTranslateService(baseUrl: 'http://localhost:5000').isAvailable();
    if (mounted) {
      setState(() {
        _argosAvailable = argosAvail;
        _libreAvailable = libreAvail;
        if (!_libreAvailable && _argosAvailable) {
          _engine = TranslationEngine.argos;
        }
      });
    }
  }

  TranslationService get _currentService {
    if (_engine == TranslationEngine.argos) {
      return ArgosTranslateService();
    }
    return LibreTranslateService(baseUrl: 'http://localhost:5000');
  }

  // ── File picking ─────────────────────────────────────────────────────────────

  Future<void> _pickInputFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt', 'ass', 'ssa'],
    );
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path!;
      final track = await SubtitleParser.parseFile(path);
      setState(() {
        _inputPath = path;
        _originalTrack = track;
        _translatedTrack = null;
        _savedPath = null;
        _error = null;
      });
    }
  }

  // ── Translation ──────────────────────────────────────────────────────────────

  Future<void> _startTranslation() async {
    if (_originalTrack == null) return;

    setState(() {
      _isTranslating = true;
      _progressCurrent = 0;
      _progressTotal = _originalTrack!.entries.length;
      _translatedTrack = null;
      _error = null;
    });

    try {
      final translator = SubtitleTranslator(
        translationService: _currentService,
      );

      final translated = await translator.translateTrack(
        _originalTrack!,
        _targetLang,
        sourceLanguage: _sourceLang == 'auto' ? null : _sourceLang,
        onProgress: (cur, total) {
          if (mounted) {
            setState(() {
              _progressCurrent = cur;
              _progressTotal = total;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _translatedTrack = translated;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _saveTranslatedFile() async {
    final track = _translatedTrack;
    if (track == null || _inputPath == null) return;

    final outPath = _inputPath!.replaceFirst(
      RegExp(r'\.(srt|vtt|ass|ssa)$', caseSensitive: false),
      '.$_targetLang.srt',
    );

    final content = generateSRT(track);
    await File(outPath).writeAsString(content, flush: true);

    if (mounted) {
      setState(() => _savedPath = outPath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to $outPath'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subtitle Translation',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Translate subtitle files offline (Argos) or via LibreTranslate',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // ── Engine selector ────────────────────────────────────────────────
          _buildCard(
            title: 'Translation Engine',
            icon: Icons.memory,
            child: Column(
              children: [
                _buildEngineOption(
                  TranslationEngine.libre,
                  title: 'LibreTranslate',
                  subtitle: 'Self-hosted server at localhost:5000',
                  available: _libreAvailable,
                ),
                const SizedBox(height: 8),
                _buildEngineOption(
                  TranslationEngine.argos,
                  title: 'Argos Translate (Offline)',
                  subtitle: 'pip install argostranslate langdetect',
                  available: _argosAvailable,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Language selection ─────────────────────────────────────────────
          _buildCard(
            title: 'Languages',
            icon: Icons.language,
            child: Row(
              children: [
                Expanded(
                  child: _buildLangDropdown(
                    label: 'Source Language',
                    value: _sourceLang,
                    options: const {
                      'auto': 'Auto-detect',
                      'en': 'English',
                      'ar': 'العربية',
                      'fr': 'Français',
                      'de': 'Deutsch',
                      'es': 'Español',
                      'tr': 'Türkçe',
                      'ru': 'Русский',
                      'zh': '中文',
                    },
                    onChanged: (v) => setState(() => _sourceLang = v!),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.arrow_forward, color: Colors.green),
                ),
                Expanded(
                  child: _buildLangDropdown(
                    label: 'Target Language',
                    value: _targetLang,
                    options: const {
                      'ar': 'العربية',
                      'en': 'English',
                      'fr': 'Français',
                      'de': 'Deutsch',
                      'es': 'Español',
                      'tr': 'Türkçe',
                      'ru': 'Русский',
                      'zh': '中文',
                      'ur': 'اردو',
                      'fa': 'فارسی',
                      'id': 'Bahasa Indonesia',
                    },
                    onChanged: (v) => setState(() => _targetLang = v!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── File input ─────────────────────────────────────────────────────
          _buildCard(
            title: 'Subtitle File',
            icon: Icons.subtitles,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _inputPath != null
                            ? _inputPath!.split(r'\').last.split('/').last
                            : 'No file selected',
                        style: TextStyle(
                          color: _inputPath != null
                              ? Colors.white
                              : Colors.grey,
                          fontFamily: _inputPath != null ? 'monospace' : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _pickInputFile,
                      icon: const Icon(Icons.folder_open, size: 18),
                      label: const Text('Browse'),
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.green),
                    ),
                  ],
                ),
                if (_originalTrack != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.list,
                        label: '${_originalTrack!.entries.length} entries',
                      ),
                      const SizedBox(width: 8),
                      if (_originalTrack!.language != null)
                        _InfoChip(
                          icon: Icons.language,
                          label: _originalTrack!.language!,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Translate button ───────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: (_originalTrack == null || _isTranslating)
                  ? null
                  : _startTranslation,
              icon: _isTranslating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.translate),
              label: Text(
                _isTranslating
                    ? 'Translating... $_progressCurrent / $_progressTotal'
                    : 'Translate Subtitle File',
                style: const TextStyle(fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.green.withValues(alpha: 0.4),
              ),
            ),
          ),

          // ── Progress bar ───────────────────────────────────────────────────
          if (_isTranslating && _progressTotal > 0) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: _progressCurrent / _progressTotal,
              backgroundColor: Colors.white10,
              color: Colors.green,
            ),
          ],

          // ── Error ──────────────────────────────────────────────────────────
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],

          // ── Translated preview ─────────────────────────────────────────────
          if (_translatedTrack != null) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Translated Preview',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                FilledButton.icon(
                  onPressed: _saveTranslatedFile,
                  icon: const Icon(Icons.save, size: 18),
                  label: Text(_savedPath != null ? 'Saved ✓' : 'Save File'),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        _savedPath != null ? Colors.grey : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _translatedTrack!.entries.length
                    .clamp(0, 50), // Preview first 50
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Colors.white10),
                itemBuilder: (_, i) {
                  final entry = _translatedTrack!.entries[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          alignment: Alignment.topCenter,
                          child: Text(
                            '${entry.index}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.text,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_translatedTrack!.entries.length > 50)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+ ${_translatedTrack!.entries.length - 50} more entries',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ── Shared builders ──────────────────────────────────────────────────────────

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.green),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF3A3A3A)),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildEngineOption(
    TranslationEngine engine, {
    required String title,
    required String subtitle,
    required bool available,
  }) {
    final isSelected = _engine == engine;
    return InkWell(
      onTap: () => setState(() => _engine = engine),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<TranslationEngine>(
              value: engine,
              groupValue: _engine,
              onChanged: (v) => setState(() => _engine = v!),
              activeColor: Colors.green,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: available
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                available ? '● Available' : '○ Unavailable',
                style: TextStyle(
                  color: available ? Colors.green : Colors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangDropdown({
    required String label,
    required String value,
    required Map<String, String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF2A2A2A),
            items: options.entries
                .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ─── Helper widget ────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }
}
