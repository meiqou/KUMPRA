import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'Easy Online\nMarket Shopping',
      subtitle: 'Order fresh goods from Libertad and share\ndelivery fees with your neighbors.',
      cta: 'GET STARTED',
      isIntro: true,
    ),
    _OnboardingPage(
      step: '1.',
      title: 'JOIN A BATCH',
      subtitle: 'Join a "Geographic Batch" on your street to share fees and clear Libertad traffic.',
      cta: 'I UNDERSTAND',
    ),
    _OnboardingPage(
      step: '2.',
      title: 'SHARED FEES',
      subtitle: 'By grouping with neighbors, you will split the delivery fee. This will make fresh produce affordable for every family in your cluster.',
      cta: 'NEXT',
    ),
    _OnboardingPage(
      step: '3.',
      title: 'MARKET ROWS',
      subtitle: 'Shop by "Rows" (Wet, Meat, Veg). This will help your rider navigate your order efficiently.',
      cta: 'JOIN NOW',
    ),
  ];

  void _next() {
    if (_current < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>  LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _pages[i].isIntro
                ? _IntroPage(page: _pages[i], onTap: _next)
                : _StepPage(page: _pages[i], onTap: _next),
          ),
          if (_current > 0)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: const WormEffect(
                    dotColor: Colors.white30,
                    activeDotColor: AppColors.primary,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String? step;
  final String title;
  final String subtitle;
  final String cta;
  final bool isIntro;

  _OnboardingPage({
    this.step,
    required this.title,
    required this.subtitle,
    required this.cta,
    this.isIntro = false,
  });
}

class _IntroPage extends StatelessWidget {
  final _OnboardingPage page;
  final VoidCallback onTap;

  const _IntroPage({required this.page, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1a3d28), Color(0xFFF5F5F0)],
          stops: [0.5, 0.5],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF0D2818), Color(0xFF1a5c35)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.storefront_rounded, size: 120, color: Colors.white24),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 30,
                    child: Text(
                      'KUMPRA',
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      page.title,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      page.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          page.cta,
                          style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepPage extends StatelessWidget {
  final _OnboardingPage page;
  final VoidCallback onTap;

  const _StepPage({required this.page, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.all(36),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              page.step ?? '',
              style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              page.title,
              style: GoogleFonts.poppins(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              page.subtitle,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  page.cta,
                  style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
