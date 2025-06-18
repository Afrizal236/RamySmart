import 'package:flutter/material.dart';
import 'package:ramysmart/util/constants.dart';
import 'package:ramysmart/screens/Home/database/firebase_service.dart';
import 'package:ramysmart/screens/Home/course_home.dart';
import 'package:ramysmart/screens/intro/intro_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Tampilkan splash screen selama 2 detik
      await Future.delayed(const Duration(seconds: 2));

      // Pastikan widget masih mounted sebelum melanjutkan
      if (!mounted) return;

      // Cek apakah user sudah login
      final currentUser = _firebaseService.getCurrentUser();

      if (currentUser != null) {
        print('SplashScreen: User sudah login: ${currentUser.email}');

        // Cek status SNBT questionnaire
        bool shouldShowSNBTIcon = await _checkSNBTStatus();

        // User sudah login, langsung ke CourseHome
        _navigateToHome(shouldShowSNBTIcon);
      } else {
        print('SplashScreen: User belum login, ke IntroScreen');

        // User belum login, ke IntroScreen
        _navigateToIntro();
      }
    } catch (e) {
      print('SplashScreen: Error checking auth status: $e');

      // Jika ada error, arahkan ke IntroScreen untuk keamanan
      if (mounted) {
        _navigateToIntro();
      }
    }
  }

  // Cek status SNBT questionnaire dari SharedPreferences
  Future<bool> _checkSNBTStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // Cek apakah user pernah menyelesaikan SNBT questionnaire
    bool hasCompletedSNBT = prefs.getBool('snbt_completed') ?? false;

    // Cek apakah user pernah menutup floating icon secara permanen
    bool hasClosedIconPermanently = prefs.getBool('snbt_icon_closed_permanently') ?? false;

    // Icon muncul jika:
    // 1. User belum menyelesaikan SNBT questionnaire DAN
    // 2. User belum menutup icon secara permanen
    return !hasCompletedSNBT && !hasClosedIconPermanently;
  }

  void _navigateToHome(bool showSNBTIcon) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CourseHome(
          showSNBTPopup: false, // Set false karena kita gunakan floating icon
          showSNBTFloatingIcon: showSNBTIcon,
        ),
      ),
    );
  }

  void _navigateToIntro() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const IntroScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo aplikasi
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  "assets/images/intro/intro.jpg",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.school,
                      size: 60,
                      color: kPrimaryColor,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Nama aplikasi
            const Text(
              "RamySmart",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Tagline
            const Text(
              "Grow Your Skills",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 50),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),

            const Text(
              "Loading...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}