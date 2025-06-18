import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Pastikan file ini ada
import 'package:ramysmart/util/constants.dart';
import 'package:ramysmart/screens/intro/splash_screen.dart'; // Sesuaikan path
import 'package:ramysmart/screens/intro/intro_screen.dart';
import 'package:ramysmart/screens/intro/login_screen.dart'; // Atau auth/login_screen.dart
import 'package:ramysmart/screens/intro/signup_screen.dart'; // Atau auth/signup_screen.dart
import 'package:ramysmart/screens/Home/course_home.dart';
import 'package:ramysmart/util/route_name.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Gunakan firebase_options jika tersedia
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    // Fallback jika firebase_options tidak tersedia
    await Firebase.initializeApp();
    print('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RamySmart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: kPrimaryColor, // Pastikan kPrimaryColor didefinisikan di constants.dart
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),

      // Hapus home property dan gunakan initialRoute
      initialRoute: RouteNames.splash,

      // Define routes untuk navigasi
      routes: {
        RouteNames.splash: (context) => const SplashScreen(),
        RouteNames.intro: (context) => const IntroScreen(),
        RouteNames.login: (context) => const LoginScreen(),
        RouteNames.signup: (context) => const SignupScreen(),
        RouteNames.courseHome: (context) => const CourseHome(), // Sesuaikan dengan constructor
      },

      // Handle route generation untuk route yang tidak terdefinisi atau butuh parameter
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case RouteNames.splash:
            return MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            );
          case RouteNames.intro:
            return MaterialPageRoute(
              builder: (context) => const IntroScreen(),
            );
          case RouteNames.login:
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          case RouteNames.signup:
            return MaterialPageRoute(
              builder: (context) => const SignupScreen(),
            );
          case RouteNames.courseHome:
            return MaterialPageRoute(
              builder: (context) => const CourseHome(showSNBTPopup: false),
            );
          default:
          // Fallback ke splash screen untuk route yang tidak dikenal
            return MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            );
        }
      },
    );
  }
}