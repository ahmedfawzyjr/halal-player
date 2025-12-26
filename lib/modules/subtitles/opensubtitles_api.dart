// Halal Player - OpenSubtitles Integration
//
// API client for OpenSubtitles to download subtitles

import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// OpenSubtitles API client
class OpenSubtitlesAPI {
  /// Default API key for Halal Player
  static const String defaultApiKey = 'D4uno2syIAeCp0fEdtRzuEIvejhK1C3t50';
  
  OpenSubtitlesAPI({
    String? apiKey,
    this.userAgent = 'HalalPlayer v1.0',
  }) : apiKey = apiKey ?? defaultApiKey,
       _dio = Dio(BaseOptions(
    baseUrl: 'https://api.opensubtitles.com/api/v1',
    headers: {
      'Content-Type': 'application/json',
      'Api-Key': apiKey ?? defaultApiKey,
      'User-Agent': userAgent,
    },
  ));

  final String apiKey;
  final String userAgent;
  final Dio _dio;
  
  String? _authToken;

  /// Login to get auth token (optional for some features)
  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'username': username,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        _authToken = response.data['token'];
        _dio.options.headers['Authorization'] = 'Bearer $_authToken';
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Search subtitles by movie hash
  Future<List<SubtitleSearchResult>> searchByHash(String hash, {
    String? language,
    int? limit = 10,
  }) async {
    try {
      final response = await _dio.get('/subtitles', queryParameters: {
        'moviehash': hash,
        if (language != null) 'languages': language,
        if (limit != null) 'per_page': limit,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((e) => SubtitleSearchResult.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Search subtitles by query (filename, title)
  Future<List<SubtitleSearchResult>> searchByQuery(String query, {
    String? language,
    int? year,
    int? limit = 10,
  }) async {
    try {
      final response = await _dio.get('/subtitles', queryParameters: {
        'query': query,
        if (language != null) 'languages': language,
        if (year != null) 'year': year,
        if (limit != null) 'per_page': limit,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((e) => SubtitleSearchResult.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Download a subtitle file
  Future<String?> download(int fileId, {String? savePath}) async {
    try {
      // First get download info
      final response = await _dio.post('/download', data: {
        'file_id': fileId,
      });

      if (response.statusCode != 200) return null;

      final downloadLink = response.data['link'] as String?;
      if (downloadLink == null) return null;

      // Download the file
      final downloadResponse = await Dio().get(
        downloadLink,
        options: Options(responseType: ResponseType.bytes),
      );

      // Save to file
      final tempDir = await getTemporaryDirectory();
      final fileName = 'subtitle_$fileId.srt';
      final filePath = savePath ?? p.join(tempDir.path, fileName);
      
      final file = File(filePath);
      await file.writeAsBytes(downloadResponse.data);

      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Calculate OpenSubtitles hash for a video file
  static Future<String?> calculateHash(String videoPath) async {
    try {
      final file = File(videoPath);
      if (!await file.exists()) return null;

      final fileSize = await file.length();
      const chunkSize = 65536; // 64KB

      if (fileSize < chunkSize * 2) return null;

      var hash = fileSize;

      // Read first 64KB
      final raf = await file.open();
      final firstChunk = await raf.read(chunkSize);
      hash = _addBytes(hash, firstChunk);

      // Read last 64KB
      await raf.setPosition(fileSize - chunkSize);
      final lastChunk = await raf.read(chunkSize);
      hash = _addBytes(hash, lastChunk);

      await raf.close();

      // Convert to hex string
      return hash.toRadixString(16).padLeft(16, '0');
    } catch (e) {
      return null;
    }
  }

  /// Add bytes to hash
  static int _addBytes(int hash, Uint8List bytes) {
    for (var i = 0; i < bytes.length; i += 8) {
      var value = 0;
      for (var j = 0; j < 8 && i + j < bytes.length; j++) {
        value |= (bytes[i + j] & 0xFF) << (8 * j);
      }
      hash += value;
      hash &= 0xFFFFFFFFFFFFFFFF; // Keep 64 bits
    }
    return hash;
  }
}

/// Subtitle search result from OpenSubtitles
class SubtitleSearchResult {
  const SubtitleSearchResult({
    required this.id,
    required this.fileId,
    required this.language,
    this.release,
    this.downloadCount,
    this.rating,
    this.isHearingImpaired = false,
    this.machineTranslated = false,
  });

  final String id;
  final int fileId;
  final String language;
  final String? release;
  final int? downloadCount;
  final double? rating;
  final bool isHearingImpaired;
  final bool machineTranslated;

  factory SubtitleSearchResult.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? json;
    final files = (attributes['files'] as List?)?.first;
    
    return SubtitleSearchResult(
      id: json['id']?.toString() ?? '',
      fileId: files?['file_id'] ?? 0,
      language: attributes['language'] ?? '',
      release: attributes['release'] ?? files?['file_name'],
      downloadCount: attributes['download_count'],
      rating: (attributes['ratings'] as num?)?.toDouble(),
      isHearingImpaired: attributes['hearing_impaired'] == true,
      machineTranslated: attributes['machine_translated'] == true,
    );
  }

  @override
  String toString() => 'SubtitleSearchResult($language: $release)';
}

/// Subtitle download manager with caching
class SubtitleDownloadManager {
  SubtitleDownloadManager({
    required this.api,
  });

  final OpenSubtitlesAPI api;
  final Map<String, String> _cache = {};

  /// Find and download best matching subtitle
  Future<String?> findAndDownload(
    String videoPath, {
    String? preferredLanguage,
  }) async {
    // Check cache first
    final cacheKey = '$videoPath:$preferredLanguage';
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (await File(cached).exists()) {
        return cached;
      }
    }

    // Calculate hash
    final hash = await OpenSubtitlesAPI.calculateHash(videoPath);
    
    List<SubtitleSearchResult> results = [];
    
    // Try hash search first
    if (hash != null) {
      results = await api.searchByHash(hash, language: preferredLanguage);
    }
    
    // Fallback to filename search
    if (results.isEmpty) {
      final filename = p.basenameWithoutExtension(videoPath);
      // Clean filename
      final cleanName = filename
          .replaceAll(RegExp(r'\[.*?\]'), '')
          .replaceAll(RegExp(r'\(.*?\)'), '')
          .replaceAll(RegExp(r'[._-]'), ' ')
          .trim();
      
      results = await api.searchByQuery(cleanName, language: preferredLanguage);
    }

    if (results.isEmpty) return null;

    // Sort by download count and rating
    results.sort((a, b) {
      final aScore = (a.downloadCount ?? 0) + ((a.rating ?? 0) * 1000).toInt();
      final bScore = (b.downloadCount ?? 0) + ((b.rating ?? 0) * 1000).toInt();
      return bScore.compareTo(aScore);
    });

    // Download best result
    final best = results.first;
    final downloadPath = await api.download(best.fileId);

    if (downloadPath != null) {
      _cache[cacheKey] = downloadPath;
    }

    return downloadPath;
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
  }
}
