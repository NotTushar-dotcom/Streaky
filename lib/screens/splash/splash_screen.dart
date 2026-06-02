import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/providers/auth_provider.dart';
import 'package:streaky/providers/user_provider.dart';
import 'package:streaky/providers/streak_provider.dart';
import 'package:streaky/widgets/particle_background.dart';

/// Screen 1 — Splash Screen
///
/// Matches the branded design: floating mascot logo at top,
/// bold tagline with orange-highlighted keywords, and particles.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Entry animation (scale + fade in)
  late AnimationController _entryController;
  late Animation<double> _entryScale;
  late Animation<double> _entryOpacity;

  // Continuous floating bob animation for the logo
  late AnimationController _floatController;
  late Animation<double> _floatOffset;

  // Text fade-in animation
  late AnimationController _textController;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  // Subtitle fade-in animation
  late AnimationController _subtitleController;
  late Animation<double> _subtitleOpacity;

  @override
  void initState() {
    super.initState();

    // --- Entry animation (logo scales in with elastic bounce) ---
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _entryScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.elasticOut,
      ),
    );

    _entryOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // --- Continuous floating bob ---
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _floatOffset = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    // --- Text fade + slide in ---
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // --- Subtitle fade in ---
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeIn),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Start logo entry
    await Future.delayed(const Duration(milliseconds: 300));
    _entryController.forward();

    // Start floating bob (loops forever)
    _floatController.repeat(reverse: true);

    // Fade in main tagline text
    await Future.delayed(const Duration(milliseconds: 900));
    _textController.forward();

    // Fade in subtitle
    await Future.delayed(const Duration(milliseconds: 500));
    _subtitleController.forward();

    // Navigate after showing the splash
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      _initializeAndNavigate();
    }
  }

  void _initializeAndNavigate() {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isLoggedIn) {
      // Init user & streak providers
      context.read<UserProvider>().init(authProvider.uid);
      context.read<StreakProvider>().init(authProvider.uid);
      context.go('/home');
    } else {
      context.go('/auth');
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    _textController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ParticleBackground(
        particleCount: 50,
        particleColor: AppColors.primaryOrange,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Floating animated logo ──
              AnimatedBuilder(
                animation: Listenable.merge([_entryController, _floatController]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _entryOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _floatOffset.value),
                      child: Transform.scale(
                        scale: _entryScale.value,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryOrange.withAlpha(80),
                                blurRadius: 50,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(36),
                            child: Image.asset(
                              'assets/images/app_logo.gif',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // ── "Build streaks." with orange keyword ──
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _textSlide,
                    child: Opacity(
                      opacity: _textOpacity.value,
                      child: child,
                    ),
                  );
                },
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Build ',
                        style: GoogleFonts.fredoka(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: 'streaks.',
                        style: GoogleFonts.fredoka(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryOrange,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // ── "Build you." with orange keyword ──
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _textSlide,
                    child: Opacity(
                      opacity: _textOpacity.value,
                      child: child,
                    ),
                  );
                },
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Build ',
                        style: GoogleFonts.fredoka(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: 'you.',
                        style: GoogleFonts.fredoka(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryOrange,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Subtitle with orange keywords ──
              AnimatedBuilder(
                animation: _subtitleController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _subtitleOpacity.value,
                    child: child,
                  );
                },
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Everyday ',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: 'consistency',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryOrange,
                          height: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: ',\n',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: 'extraordinary',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryOrange,
                          height: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: ' results.',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
