import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'login_page.dart';
import 'onboarding_page.dart';
import 'main_shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isReady = false;
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    // Temporarily forcing to TRUE so you can see it right now for testing:
    _isFirstLaunch = true; // prefs.getBool('isFirstLaunch') ?? true;
    
    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  void _continue() async {
    if (!_isReady) return;
    
    final authState = context.read<AuthBloc>().state;
    
    if (_isFirstLaunch) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      if (authState is AuthAuthenticated) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainShell(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _continue,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                )
                .animate()
                .fade(duration: 800.ms)
                .scaleXY(begin: 0.8, end: 1.0, duration: 800.ms, curve: Curves.easeOutCubic),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 80.0), // Увеличил отступ снизу
                child: const Text(
                  'коснитесь экрана чтобы продолжить',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(begin: 0.4, end: 1.0, duration: 1.seconds),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
