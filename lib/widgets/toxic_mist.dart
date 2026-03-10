import 'dart:async';
import 'dart:math';
import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';

class ToxicMist extends StatefulWidget {
  final Widget child;
  const ToxicMist({super.key, required this.child});

  @override
  State<ToxicMist> createState() => _ToxicMistState();
}

class _ToxicMistState extends State<ToxicMist> {
  Alignment _align1 = Alignment.topLeft;
  Alignment _align2 = Alignment.bottomRight;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimationLoop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAnimationLoop() {
    // Moves the light blobs every 4 seconds to simulate fluid flow
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _align1 = _randomAlignment();
          _align2 = _randomAlignment();
        });
      }
    });
  }

  Alignment _randomAlignment() {
    final rng = Random();
    return Alignment(rng.nextDouble() * 2 - 1, rng.nextDouble() * 2 - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. BLACK BASE
        Container(color: Colors.black),

        // 2. THE LIGHT BLOBS (Acid Lime & Cyan)
        AnimatedAlign(
          duration: const Duration(seconds: 4),
          curve: Curves.easeInOutSine,
          alignment: _align1,
          child: _buildGlowOrb(const Color(0xFFE5FF65).withOpacity(0.2)),
        ),
        
        AnimatedAlign(
          duration: const Duration(seconds: 6),
          curve: Curves.easeInOutSine,
          alignment: _align2,
          child: _buildGlowOrb(const Color(0xFF00ffff).withOpacity(0.15)),
        ),

        // 3. THE BLUR LAYER (Turns blobs into smoke)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              color: Colors.black.withOpacity(0.3), 
            ),
          ),
        ),

        // 4. THE UI CONTENT
        widget.child,
      ],
    );
  }

  Widget _buildGlowOrb(Color color) {
    return Container(
      height: 450,
      width: 450,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}