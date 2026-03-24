import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_management/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _skipOnboarding() {
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.bgDark,
          gradient: AppTheme.slateGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        AppLocalizations.of(context)!.skip,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Text(
                        '${AppLocalizations.of(context)!.step} ${_currentPage + 1} / $_totalPages',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildPage(
                      AppLocalizations.of(context)!.onboard1Title,
                      AppLocalizations.of(context)!.onboard1Sub,
                      AppLocalizations.of(context)!.onboard1Desc,
                      Icons.recycling_rounded,
                    ),
                    _buildPage(
                      AppLocalizations.of(context)!.onboard2Title,
                      AppLocalizations.of(context)!.onboard2Sub,
                      AppLocalizations.of(context)!.onboard2Desc,
                      Icons.schedule_rounded,
                    ),
                    _buildPage(
                      AppLocalizations.of(context)!.onboard3Title,
                      AppLocalizations.of(context)!.onboard3Sub,
                      AppLocalizations.of(context)!.onboard3Desc,
                      Icons.stars_rounded,
                    ),
                    _buildPage(
                      AppLocalizations.of(context)!.onboard4Title,
                      AppLocalizations.of(context)!.onboard4Sub,
                      AppLocalizations.of(context)!.onboard4Desc,
                      Icons.eco_rounded,
                    ),
                  ],
                ),
              ),
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page indicators
                    Row(
                      children: List.generate(
                        _totalPages,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 40 : 10,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppTheme.primaryEmerald
                                : Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    // Next/Skip button
                    SizedBox(
                      height: 64,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.bgDark,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Row(
                            children: [
                              Text(
                                _currentPage == _totalPages - 1 ? AppLocalizations.of(context)!.getStarted : AppLocalizations.of(context)!.continueText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                _currentPage == _totalPages - 1 ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded, 
                                size: 20, 
                                color: AppTheme.primaryEmerald
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(String title, String subtitle, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container with premium glass effect
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryEmerald.withValues(alpha: 0.1),
                  blurRadius: 60,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                gradient: AppTheme.emeraldGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryEmerald.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 52,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 64),
          // Title
          Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 32,
              letterSpacing: -1,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Subtitle
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.primaryEmerald,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            description,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
