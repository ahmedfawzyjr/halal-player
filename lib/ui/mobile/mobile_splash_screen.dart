import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class MobileSplashScreen extends StatefulWidget {
  const MobileSplashScreen({super.key, required this.onFinished});
  final VoidCallback onFinished;

  @override
  State<MobileSplashScreen> createState() => _MobileSplashScreenState();
}

class _MobileSplashScreenState extends State<MobileSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();

    // End splash after 3 seconds
    Timer(const Duration(milliseconds: 3200), () {
      _fadeController.reverse().then((_) => widget.onFinished());
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Animated Background Islamic Geometric Pattern
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.04,
                  child: Transform.rotate(
                    angle: _rotateController.value * 2 * math.pi,
                    child: CustomPaint(
                      painter: _IslamicPatternPainter(),
                    ),
                  ),
                );
              },
            ),
          ),
          // Glow Background Effect
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.15),
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          // Logo Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Image.asset(
                        'assets/img/logo-icon.png',
                        width: 90,
                        height: 90,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.play_circle_filled,
                          size: 90,
                          color: Colors.green.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'HALAL PLAYER',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI Safe Media Player',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade400,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading Indicator at Bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.45;

    // Draw concentric 8-point stars
    for (double r = 40; r < maxRadius; r += 40) {
      _drawStar8(canvas, center, r, paint);
      _drawStar8(canvas, center, r + 20, paint, rotateRad: math.pi / 8);
    }
  }

  void _drawStar8(Canvas canvas, Offset center, double radius, Paint paint,
      {double rotateRad = 0.0}) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + rotateRad;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final path2 = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + rotateRad + math.pi / 8;
      final x = center.dx + radius * 0.7 * math.cos(angle);
      final y = center.dy + radius * 0.7 * math.sin(angle);
      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }
    path2.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
