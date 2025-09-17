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
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Logo spark and pulse
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _logoScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _logoController.repeat(reverse: true, period: const Duration(seconds: 2));
      }
    });

    // Progress bar
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: AnimationController(duration: const Duration(seconds: 5), vsync: this)..forward(),
        curve: Curves.easeInOut,
      ),
    );

    // Typewriter for tagline
    Timer(const Duration(milliseconds: 1000), () {
      setState(() => _showTagline = true);
      _typewriterEffect();
    });

    // Transition to next
    _transitionTimer = Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const AgeVerificationScreen(),
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

    return Directionality( // For RTL support (Arabic)
      textDirection: TextDirection.ltr, // Default LTR; change to rtl for Arabic
      child: Scaffold(
        body: Stack(
          children: [
            // Gradient background (black to deep purple, softer for eyes)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A0033), Color(0xFF000000)],
                ),
              ),
            ),

            // Particles with glow trails (purple, blue, yellow, orange for mix)
            CircularParticle(
              key: UniqueKey(),
              awayRadius: size.height / 2,
              numberOfParticles: 50,
              speedOfParticles: 0.5, // Slower for trails
              height: size.height,
              width: size.width,
              onTapAnimation: false,
              particleColor: [Colors.purple, Colors.blue, Colors.yellow, Colors.orange],
              awayAnimationDuration: const Duration(milliseconds: 1000),
              maxParticleSize: 5,
              isRandSize: true,
              isRandomColor: true,
              connectDots: false,
              enableHover: false,
              emissionFrequency: 0.2, // For subtle trails
            ),

            // Logo with pulse and crackling
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
                          color: const Color(0xFF00D4FF), // Blue
                          shadows: [
                            Shadow(color: const Color(0xFFFFFF00).withOpacity(0.6), blurRadius: 15), // Yellow glow, softer
                            Shadow(color: Colors.orange.withOpacity(0.4), blurRadius: 10), // Orange accent
                          ],
                        ),
                        // Crackling edges with CustomPainter
                        CustomPaint(
                          size: Size(isLandscape ? size.height * 0.3 : size.width * 0.5, isLandscape ? size.height * 0.3 : size.width * 0.5),
                          painter: CracklingPainter(_logoController.value, _random),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // App name with neon
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
                    Shadow(color: const Color(0xFF00D4FF).withOpacity(0.7), blurRadius: 8), // Neon, softer
                  ],
                ),
              ),
            ),

            // Tagline typewriter
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
                    color: Colors.yellow.withOpacity(0.8), // Softer for eyes
                  ),
                ),
              ),

            // Progress bar with lightning fill
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
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow.withOpacity(0.8)), // Softer fill
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  );
                },
              ),
            ),

            // Random lightning streaks (enhanced with animation)
            ...List.generate(3, (index) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                top: _random.nextDouble() * size.height,
                left: _random.nextDouble() * size.width,
                child: AnimatedOpacity(
                  opacity: _random.nextDouble() * 0.7 + 0.3, // Varying opacity
                  duration: const Duration(milliseconds: 800),
                  child: Transform.rotate(
                    angle: _random.nextDouble() * pi,
                    child: Container(
                      width: 150 + _random.nextDouble() * 100,
                      height: 2,
                      decoration: BoxDecoration(
                        color: [_random.nextBool() ? Colors.blue : Colors.yellow, Colors.orange, Colors.red][_random.nextInt(3)].withOpacity(0.6),
                        boxShadow: [
                          BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 5), // Glow for streak
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// CustomPainter for crackling lightning around logo edges
class CracklingPainter extends CustomPainter {
  final double animationValue;
  final Random random;

  CracklingPainter(this.animationValue, this.random);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.5 * animationValue)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) { // 5 crackles
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final endX = startX + (random.nextDouble() * 20 - 10);
      final endY = startY + (random.nextDouble() * 20 - 10);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);

      // Branching for realism
      final branchX = endX + (random.nextDouble() * 10 - 5);
      final branchY = endY + (random.nextDouble() * 10 - 5);
      canvas.drawLine(Offset(endX, endY), Offset(branchX, branchY), paint..color = Colors.blue.withOpacity(0.4));
    }
  }

  @override
  bool shouldRepaint(CracklingPainter oldDelegate) => animationValue != oldDelegate.animationValue;
}

// Placeholder for next screen
class AgeVerificationScreen extends StatelessWidget {
  const AgeVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Age Verification Screen - Coming Next!')),
    );
  }
}
