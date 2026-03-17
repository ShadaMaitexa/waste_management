import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final success = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Redirection based on actual role from backend
        final currentUserType = authService.currentUser?.userType;
        
        // Default to resident if profile fetch succeeded but userType is unknown
        String route;
        switch (currentUserType) {
          case UserType.worker:
            route = '/worker';
            break;
          case UserType.admin:
            route = '/admin';
            break;
          case UserType.recycler:
            route = '/recycler';
            break;
          case UserType.resident:
          default:
            route = '/resident';
            break;
        }

        Navigator.pushReplacementNamed(context, route);
      } else if (mounted) {
        _showErrorSnackBar('Check your email and password');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      body: Stack(
        children: [
          // Elevated Gradient Background
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.bgSurface,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.bgSurface, Color(0xFFF1F8E9)],
              ),
            ),
          ),
          // Subtle Eco Patterns
          Positioned(
            right: -100,
            top: -50,
            child: Icon(
              Icons.eco_rounded,
              size: 300,
              color: AppTheme.primaryEmerald.withValues(alpha: 0.05),
            ),
          ),
          Positioned(
            left: -150,
            bottom: -100,
            child: Icon(
              Icons.blur_on_rounded,
              size: 400,
              color: AppTheme.primaryEmerald.withValues(alpha: 0.03),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 32),
                    _buildWelcomeText(),
                    const SizedBox(height: 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildLoginForm(),
                          const SizedBox(height: 32),
                          _buildLoginButton(),
                          const SizedBox(height: 24),
                          _buildForgotPassword(),
                          const SizedBox(height: 48),
                          _buildSignUpPrompt(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Center(
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppTheme.emeraldGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.recycling_rounded,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'GreenLoop',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppTheme.grey900,
            letterSpacing: -1.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'SMART LOGISTICS ECOSYSTEM',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.primaryEmerald,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Login to your account',
          style: GoogleFonts.inter(
            color: AppTheme.grey400,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }


  Widget _buildLoginForm() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppTheme.grey900),
          decoration: const InputDecoration(
            hintText: 'Email address',
            prefixIcon: Icon(Icons.alternate_email_rounded, size: 20, color: AppTheme.primaryEmerald),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Email is required';
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppTheme.grey900),
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppTheme.primaryEmerald),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 20,
                color: AppTheme.grey400,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Password is required';
            if (value.length < 6) return 'At least 6 characters';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.bgDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppTheme.slateGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.bgDark.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'LOGIN',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.bolt_rounded, size: 20, color: AppTheme.primaryEmerald),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: _navigateToForgotPassword,
      child: Text(
        'FORGOT PASSWORD?',
        style: GoogleFonts.plusJakartaSans(
          color: AppTheme.grey400, 
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account?',
          style: GoogleFonts.inter(color: AppTheme.grey400, fontWeight: FontWeight.w600, fontSize: 13),
        ),
        TextButton(
          onPressed: _navigateToSignUp,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            foregroundColor: AppTheme.primaryEmerald,
          ),
          child: Text(
            'Sign Up',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}
