import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streaky/config/app_colors.dart';
import 'package:streaky/config/app_text_styles.dart';
import 'package:streaky/providers/auth_provider.dart';
import 'package:streaky/providers/user_provider.dart';
import 'package:streaky/providers/streak_provider.dart';
import 'package:streaky/widgets/particle_background.dart';

/// Authentication screen — shown on first launch when user is not logged in.
///
/// Provides Google Sign-In and Email/Password authentication.
/// Once authenticated, the user stays logged in permanently
/// (Firebase handles session persistence).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isSignUp = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();
    if (success && mounted) {
      _navigateToHome();
    } else if (mounted) {
      final error = authProvider.error ?? 'Google Sign-In failed';
      debugPrint('Google Sign-In Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    bool success;

    if (_isSignUp) {
      success = await authProvider.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
      );
    } else {
      success = await authProvider.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }

    if (success && mounted) {
      _navigateToHome();
    } else if (mounted) {
      final error = authProvider.error ?? 'Authentication failed';
      debugPrint('Email Auth Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToHome() {
    final authProvider = context.read<AuthProvider>();
    context.read<UserProvider>().init(authProvider.uid);
    context.read<StreakProvider>().init(authProvider.uid);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ParticleBackground(
        particleCount: 35,
        particleColor: AppColors.primaryOrange,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  // App logo
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withAlpha(60),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/images/app_logo.gif',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Welcome text
                  Text(
                    'Welcome to',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Streaky',
                    style: GoogleFonts.fredoka(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Build streaks. Build you.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppColors.textHint,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Google Sign-In button
                  _GoogleSignInButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : _handleGoogleSignIn,
                  ),

                  const SizedBox(height: 20),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.surfaceLight,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textHint,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.surfaceLight,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Email/Password form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name field (sign-up only)
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _isSignUp
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _StyledTextField(
                                    controller: _nameController,
                                    hint: 'Full Name',
                                    icon: Icons.person_outline_rounded,
                                    validator: (v) {
                                      if (_isSignUp &&
                                          (v == null || v.trim().isEmpty)) {
                                        return 'Enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),

                        // Email field
                        _StyledTextField(
                          controller: _emailController,
                          hint: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter your email';
                            }
                            if (!v.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Password field
                        _StyledTextField(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: AppColors.textHint,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() =>
                                  _obscurePassword = !_obscurePassword);
                            },
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter your password';
                            }
                            if (_isSignUp && v.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Error message
                  if (authProvider.error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withAlpha(40),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: AppColors.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authProvider.error!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: GestureDetector(
                      onTap: authProvider.isLoading
                          ? null
                          : _handleEmailAuth,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF8A00),
                              Color(0xFFFF6B6B),
                              Color(0xFFFF1493),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFFFF8A00).withAlpha(40),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  _isSignUp ? 'Create Account' : 'Sign In',
                                  style: AppTextStyles.button.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Toggle sign-in / sign-up
                  GestureDetector(
                    onTap: () {
                      setState(() => _isSignUp = !_isSignUp);
                      context.read<AuthProvider>().clearError();
                    },
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: _isSignUp
                                ? 'Already have an account? '
                                : "Don't have an account? ",
                            style: AppTextStyles.bodySmall,
                          ),
                          TextSpan(
                            text: _isSignUp ? 'Sign In' : 'Sign Up',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Google Sign-In button with Google branding.
class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _GoogleSignInButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surfaceLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" icon (text-based to avoid asset dependency)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  'G',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4285F4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Styled text input field matching app design.
class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.body.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.textHint,
        ),
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.surfaceLight,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.surfaceLight,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryOrange,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
