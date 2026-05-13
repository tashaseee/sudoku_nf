import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_shell.dart';
import 'login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skip() {
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Top Left Blob
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.02),
              ),
            ),
          ),
          // Bottom Right Blob
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.02),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildPage(
                        titleBlack1: 'Развивай ',
                        titleRed: 'мозг',
                        titleBlack2: '\nкаждый день',
                        imagePath: 'assets/images/ob_grid.png',
                        description: 'Судоку — это не просто цифры, это тренировка твоего мышления.',
                      ),
                      _buildPage(
                        titleBlack1: 'Играй на своём\n',
                        titleRed: 'уровне',
                        titleBlack2: '',
                        imagePath: 'assets/images/ob_stairs.png',
                        description: 'От новичка до эксперта — выбирай\nсложность под себя.',
                      ),
                      _buildPage(
                        titleBlack1: 'Твой личный\n',
                        titleRed: 'AI-коуч',
                        titleBlack2: '',
                        imagePath: 'assets/images/ob_cat.png',
                        description: 'ИИ учит тебя играть с нуля.\nНе подсказывает — объясняет как думать.',
                      ),
                    ],
                  ),
                ),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required String titleBlack1,
    required String titleRed,
    required String titleBlack2,
    required String imagePath,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 140), // Moved title lower
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
                height: 1.2,
              ),
              children: [
                TextSpan(text: titleBlack1),
                TextSpan(
                  text: titleRed,
                  style: const TextStyle(color: Color(0xFFDD233B)),
                ),
                TextSpan(text: titleBlack2),
              ],
            ),
          ),
          
          const SizedBox(height: 16), // Reduced to move image higher relative to title
          
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0), // Reduced to move image higher
                child: Image.asset(
                  imagePath,
                  width: 240,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (description.isNotEmpty)
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: const Color(0xFF6B7280),
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
            
          const SizedBox(height: 56), // Increased from 24 to push subtext higher
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 80, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index 
                      ? const Color(0xFFDD233B)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 48),
          
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _skip,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF9CA3AF),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  'Пропустить',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDD233B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24), // Increased padding
                  minimumSize: const Size(120, 48), // Wider button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _currentPage == 2 ? 'Начать' : 'Следующее',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
