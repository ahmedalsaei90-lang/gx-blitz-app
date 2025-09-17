import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:particles_flutter/particles_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _progressAnimation;
  late Timer _transitionTimer;
  bool _showTagline = false;
  String _taglineText = '';
  final String _fullTagline = 'BLITZ YOUR LIMITS';

  @override
  void initState() {
    super.initState();

    // Logo materialization and pulse animation (0.8s spark, then pulse)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward(); // Start the spark effect

    _logoScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Repeat pulse after initial animation
    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _logoController.repeat(reverse: true, period: const Duration(seconds: 2));
      }
    });

    // Progress bar animation
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: AnimationController(duration: const Duration(seconds: 5), vsync: this)..forward(),
        curve: Curves.easeInOut,
      ),
    );

    // Typewriter animation for tagline
    Timer(const Duration(milliseconds: 1000), () {
      setState(() => _showTagline = true);
      _typewriterEffect();
    });

    // Random lightning streaks (simulated with overlays)
    Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      // We'll simulate streaks in the build method with random positions
    });

    // Transition to next screen after 5 seconds
    _transitionTimer = Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AgeVerificationScreen(), // Placeholder for next screen
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  void _typewriterEffect() {
    int index = 0;
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (index < _fullTagline.length) {
        setState(() => _taglineText += _fullTagline[index]);
        index++;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _transitionTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient (black to deep purple)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A0033), Color(0xFF000000)],
              ),
            ),
          ),

          // Floating particles (purple, blue, yellow, floating upward with glow)
          CircularParticle(
            key: UniqueKey(),
            awayRadius: size.height / 2,
            numberOfParticles: 50,
            speedOfParticles: 1,
            height: size.height,
            width: size.width,
            onTapAnimation: false,
            particleColor: [Colors.purple, Colors.blue, Colors.yellow],
            awayAnimationDuration: const Duration(milliseconds: 600),
            maxParticleSize: 4,
            isRandSize: true,
            isRandomColor: true,
            connectDots: false,
            enableHover: false,
          ),

          // Animated logo (lightning bolt with pulse and crackling)
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoScaleAnimation.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.bolt,
                        size: isLandscape ? size.height * 0.3 : size.width * 0.5,
                        color: const Color(0xFF00D4FF), // Electric blue
                        shadows: const [
                          Shadow(color: Color(0xFFFFFF00), blurRadius: 20), // Yellow glow
                        ],
                      ),
                      // Simulate crackling: Random small bolts (simple overlays)
                      ...List.generate(3, (index) {
                        final random = Random();
                        return Positioned(
                          top: random.nextDouble() * 50 - 25,
                          left: random.nextDouble() * 50 - 25,
                          child: Opacity(
                            opacity: random.nextDouble(),
                            child: Icon(
                              Icons.bolt,
                              size: 20,
                              color: Colors.yellow.withOpacity(0.5),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),

          // App name with glowing neon effect
          Positioned(
            top: size.height * 0.2,
            left: 0,
            right: 0,
            child: Text(
              'GX Blitz',
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: isLandscape ? size.height * 0.08 : size.width * 0.1,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(color: const Color(0xFF00D4FF), blurRadius: 10), // Neon glow
                ],
              ),
            ),
          ),

          // Tagline with typewriter animation
          if (_showTagline)
            Positioned(
              top: size.height * 0.35,
              left: 0,
              right: 0,
              child: Text(
                _taglineText,
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: isLandscape ? size.height * 0.04 : size.width * 0.06,
                  color: Colors.yellow,
                ),
              ),
            ),

          // Progress bar at bottom with lightning fill
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: Colors.purple.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFFF00)), // Yellow lightning fill
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                );
              },
            ),
          ),

          // Random lightning streaks across screen (simple animated lines)
          ...List.generate(2, (index) {
            final random = Random();
            return Positioned(
              top: random.nextDouble() * size.height,
              left: random.nextDouble() * size.width,
              child: AnimatedOpacity(
                opacity: random.nextBool() ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: 100,
                  height: 2,
                  color: Colors.blue,
                  transform: Matrix4.rotationZ(random.nextDouble() * pi),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Placeholder for next screen (Age Verification) - we'll implement later
class AgeVerificationScreen extends StatelessWidget {
  const AgeVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Age Verification Screen - Coming Next!')),
    );
  }
}