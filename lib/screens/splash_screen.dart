import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import 'main_screen.dart';

/// Splash Screen
/// Initial loading screen with branding and permission checks

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 2));
    
    // Navigate to home screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(delay: 200.ms, duration: 400.ms),
                
                const SizedBox(height: 32),
                
                // App Name
                const Text(
                  'MediTranscribe',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
                
                const SizedBox(height: 8),
                
                // Tagline
                const Text(
                  'HIPAA-Compliant Medical Transcription',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms),
                
                const SizedBox(height: 60),
                
                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 400.ms),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Initializing...',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1000.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
