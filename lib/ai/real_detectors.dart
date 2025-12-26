// Halal Player - AI Detectors using Python Subprocess
//
// Uses Python with ONNX/TensorFlow for NSFW detection
// This approach is simpler and more reliable than FFI

import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/ai_gateway.dart';

/// NSFW Detector using Python subprocess with NSFW model
class RealNSFWDetector implements AIDetector {
  bool _isInitialized = false;
  String? _pythonPath;
  String? _scriptPath;
  
  @override
  bool get isReady => _isInitialized;
  
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Find Python installation
      _pythonPath = await _findPython();
      if (_pythonPath == null) {
        throw Exception('Python not found. Please install Python 3.8+');
      }
      
      // Create detection script
      _scriptPath = await _createDetectionScript();
      
      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<String?> _findPython() async {
    // Try common Python locations
    final pythonCommands = ['python', 'python3', 'py'];
    
    for (final cmd in pythonCommands) {
      try {
        final result = await Process.run(cmd, ['--version']);
        if (result.exitCode == 0) {
          return cmd;
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }
  
  Future<String> _createDetectionScript() async {
    final tempDir = await getTemporaryDirectory();
    final scriptPath = p.join(tempDir.path, 'nsfw_detect.py');
    
    final script = '''
import sys
import json

try:
    from PIL import Image
    import numpy as np
    
    # Check if nsfw_detector is available
    try:
        from nsfw_detector import predict
        MODEL_PATH = None  # Use default model
        USE_NSFW_DETECTOR = True
    except ImportError:
        USE_NSFW_DETECTOR = False
        
        # Fallback: Simple color-based heuristic
        def simple_nsfw_check(image):
            # Convert to numpy array
            img_array = np.array(image)
            
            # Simple skin tone detection (very basic)
            r, g, b = img_array[:,:,0], img_array[:,:,1], img_array[:,:,2]
            
            # Skin tone detection heuristic
            skin = ((r > 95) & (g > 40) & (b > 20) & 
                    (np.maximum(r,np.maximum(g,b)) - np.minimum(r,np.minimum(g,b)) > 15) &
                    (abs(r.astype(int) - g.astype(int)) > 15) & (r > g) & (r > b))
            
            skin_ratio = np.sum(skin) / skin.size
            
            return {"safe": 1.0 - min(skin_ratio * 2, 0.9), "unsafe": min(skin_ratio * 2, 0.9)}

    def analyze_image(image_path):
        try:
            image = Image.open(image_path).convert('RGB')
            image = image.resize((224, 224))
            
            if USE_NSFW_DETECTOR:
                result = predict.classify(MODEL_PATH, image_path)
                scores = result.get(image_path, {"safe": 1.0, "unsafe": 0.0})
                return {"safe": scores.get("safe", 1.0), "nsfw": scores.get("unsafe", 0.0)}
            else:
                scores = simple_nsfw_check(image)
                return {"safe": scores["safe"], "nsfw": scores["unsafe"]}
                
        except Exception as e:
            return {"error": str(e), "safe": 1.0, "nsfw": 0.0}

    if __name__ == "__main__":
        if len(sys.argv) < 2:
            print(json.dumps({"error": "No image path provided"}))
            sys.exit(1)
            
        image_path = sys.argv[1]
        result = analyze_image(image_path)
        print(json.dumps(result))
        
except ImportError as e:
    print(json.dumps({"error": f"Missing dependency: {e}", "safe": 1.0, "nsfw": 0.0}))
except Exception as e:
    print(json.dumps({"error": str(e), "safe": 1.0, "nsfw": 0.0}))
''';
    
    await File(scriptPath).writeAsString(script);
    return scriptPath;
  }
  
  @override
  Future<DetectionResult> analyze(Uint8List imageData) async {
    if (!_isInitialized || _pythonPath == null || _scriptPath == null) {
      return const DetectionResult(
        modelName: 'NSFW-Python',
        score: 0.0,
        categories: {'safe': 1.0, 'nsfw': 0.0},
      );
    }
    
    try {
      // Save image to temp file
      final tempDir = await getTemporaryDirectory();
      final imagePath = p.join(tempDir.path, 'temp_analyze_\${DateTime.now().millisecondsSinceEpoch}.jpg');
      await File(imagePath).writeAsBytes(imageData);
      
      // Run Python script
      final result = await Process.run(
        _pythonPath!,
        [_scriptPath!, imagePath],
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
      
      // Clean up temp file
      try {
        await File(imagePath).delete();
      } catch (_) {}
      
      if (result.exitCode == 0) {
        final output = json.decode(result.stdout.toString().trim()) as Map<String, dynamic>;
        
        final nsfwScore = (output['nsfw'] as num?)?.toDouble() ?? 0.0;
        final safeScore = (output['safe'] as num?)?.toDouble() ?? 1.0;
        
        return DetectionResult(
          modelName: 'NSFW-Python',
          score: nsfwScore,
          categories: {'safe': safeScore, 'nsfw': nsfwScore},
        );
      } else {
        return const DetectionResult(
          modelName: 'NSFW-Python',
          score: 0.0,
          categories: {'safe': 1.0, 'nsfw': 0.0},
        );
      }
    } catch (e) {
      return const DetectionResult(
        modelName: 'NSFW-Python',
        score: 0.0,
        categories: {'safe': 1.0, 'nsfw': 0.0},
      );
    }
  }
  
  @override
  Future<void> dispose() async {
    _isInitialized = false;
    if (_scriptPath != null) {
      try {
        await File(_scriptPath!).delete();
      } catch (_) {}
    }
  }
}

/// NudeNet Detector using Python subprocess
class RealNudeNetDetector implements AIDetector {
  bool _isInitialized = false;
  String? _pythonPath;
  String? _scriptPath;
  
  @override
  bool get isReady => _isInitialized;
  
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _pythonPath = await _findPython();
      if (_pythonPath == null) {
        throw Exception('Python not found');
      }
      
      _scriptPath = await _createDetectionScript();
      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<String?> _findPython() async {
    final pythonCommands = ['python', 'python3', 'py'];
    
    for (final cmd in pythonCommands) {
      try {
        final result = await Process.run(cmd, ['--version']);
        if (result.exitCode == 0) {
          return cmd;
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }
  
  Future<String> _createDetectionScript() async {
    final tempDir = await getTemporaryDirectory();
    final scriptPath = p.join(tempDir.path, 'nudenet_detect.py');
    
    final script = '''
import sys
import json

try:
    from nudenet import NudeClassifier
    
    classifier = NudeClassifier()
    
    def analyze_image(image_path):
        try:
            result = classifier.classify(image_path)
            
            if image_path in result:
                data = result[image_path]
                unsafe_score = data.get('unsafe', 0.0)
                safe_score = data.get('safe', 1.0)
                return {"safe": safe_score, "nsfw": unsafe_score}
            else:
                return {"safe": 1.0, "nsfw": 0.0}
                
        except Exception as e:
            return {"error": str(e), "safe": 1.0, "nsfw": 0.0}

    if __name__ == "__main__":
        if len(sys.argv) < 2:
            print(json.dumps({"error": "No image path provided"}))
            sys.exit(1)
            
        image_path = sys.argv[1]
        result = analyze_image(image_path)
        print(json.dumps(result))
        
except ImportError:
    print(json.dumps({"safe": 1.0, "nsfw": 0.0, "error": "NudeNet not installed"}))
except Exception as e:
    print(json.dumps({"error": str(e), "safe": 1.0, "nsfw": 0.0}))
''';
    
    await File(scriptPath).writeAsString(script);
    return scriptPath;
  }
  
  @override
  Future<DetectionResult> analyze(Uint8List imageData) async {
    if (!_isInitialized || _pythonPath == null || _scriptPath == null) {
      return const DetectionResult(
        modelName: 'NudeNet-Python',
        score: 0.0,
        categories: {'safe': 1.0, 'nsfw': 0.0},
      );
    }
    
    try {
      final tempDir = await getTemporaryDirectory();
      final imagePath = p.join(tempDir.path, 'temp_nudenet_\${DateTime.now().millisecondsSinceEpoch}.jpg');
      await File(imagePath).writeAsBytes(imageData);
      
      final result = await Process.run(
        _pythonPath!,
        [_scriptPath!, imagePath],
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
      
      try {
        await File(imagePath).delete();
      } catch (_) {}
      
      if (result.exitCode == 0) {
        final output = json.decode(result.stdout.toString().trim()) as Map<String, dynamic>;
        
        final nsfwScore = (output['nsfw'] as num?)?.toDouble() ?? 0.0;
        final safeScore = (output['safe'] as num?)?.toDouble() ?? 1.0;
        
        return DetectionResult(
          modelName: 'NudeNet-Python',
          score: nsfwScore,
          categories: {'safe': safeScore, 'nsfw': nsfwScore},
        );
      } else {
        return const DetectionResult(
          modelName: 'NudeNet-Python',
          score: 0.0,
          categories: {'safe': 1.0, 'nsfw': 0.0},
        );
      }
    } catch (e) {
      return const DetectionResult(
        modelName: 'NudeNet-Python',
        score: 0.0,
        categories: {'safe': 1.0, 'nsfw': 0.0},
      );
    }
  }
  
  @override
  Future<void> dispose() async {
    _isInitialized = false;
    if (_scriptPath != null) {
      try {
        await File(_scriptPath!).delete();
      } catch (_) {}
    }
  }
}
