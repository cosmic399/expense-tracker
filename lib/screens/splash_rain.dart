import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:budget_scanner/main.dart'; // To access NeoColors and Dashboard

class SplashRain extends StatefulWidget {
  const SplashRain({super.key});

  @override
  State<SplashRain> createState() => _SplashRainState();
}

class _SplashRainState extends State<SplashRain> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<RainDrop> drops = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    // 1. Initialize Drops (Data Streams)
    // We create 100 vertical streams
    for (int i = 0; i < 100; i++) {
      drops.add(RainDrop(
        x: _rng.nextDouble(), // Random horizontal position (0.0 to 1.0)
        y: _rng.nextDouble() * -1, // Start above the screen
        speed: 0.005 + _rng.nextDouble() * 0.01, // Random speed
        length: 0.05 + _rng.nextDouble() * 0.1, // Random trail length
      ));
    }

    // 2. Start the Physics Engine
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(); // Loop forever

    // 3. Navigate to Dashboard after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const CredDashboard(),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // THE RAIN PAINTER
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: RainPainter(drops: drops, random: _rng),
                child: Container(),
              );
            },
          ),
          
          // THE LOGO (Centered)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code_scanner, color: NeoColors.lime, size: 64),
                const SizedBox(height: 16),
                Text(
                  "INITIALIZING SYSTEM...",
                  style: TextStyle(
                    color: NeoColors.lime, 
                    fontFamily: 'Courier', 
                    letterSpacing: 4, 
                    fontSize: 12,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// 💧 THE PHYSICS OBJECT
class RainDrop {
  double x;
  double y;
  double speed;
  double length;

  RainDrop({required this.x, required this.y, required this.speed, required this.length});
}

// 🎨 THE PAINTER
class RainPainter extends CustomPainter {
  final List<RainDrop> drops;
  final Random random;

  RainPainter({required this.drops, required this.random});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeoColors.lime
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;

    for (var drop in drops) {
      // 1. Move the drop down
      drop.y += drop.speed;

      // 2. Reset if it goes off screen
      if (drop.y > 1.0 + drop.length) {
        drop.y = random.nextDouble() * -0.5; // Restart above screen
        drop.speed = 0.005 + random.nextDouble() * 0.01; // New speed
      }

      // 3. Draw the Trail
      // We map 0.0-1.0 to Screen Width/Height
      final double startX = drop.x * size.width;
      final double startY = drop.y * size.height;
      final double endY = (drop.y - drop.length) * size.height;

      // Create a fading gradient for the trail
      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [NeoColors.lime, Colors.transparent],
        stops: const [0.0, 1.0],
      );

      paint.shader = gradient.createShader(Rect.fromLTRB(startX, endY, startX + 2, startY));

      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true; // Always repaint for animation
}